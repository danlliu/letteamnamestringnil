from datetime import time
import sys
import random

import pandas as pd
import numpy as np
from tqdm.auto import tqdm

import tensorflow as tf
from tensorflow.keras import layers

import CharacterData as cd

np.set_printoptions(precision=3, suppress=True)

debug_mode = False
verbose = False
testing_mode = False

data_list = cd.DataLists()


# helpers
def trim_dataset(df, cols_to_remove):
    for tag in cols_to_remove:
        if tag in df.columns:
            # df[tag] = [np.asarray(l).astype(np.str) for l in df[tag]]
            df.pop(tag)
        elif verbose or debug_mode:
            print(str(tag) + " not found in dataframe.")


def trim_strings(df, str_cols):
    for tag in str_cols:
        df[tag] = df[tag].apply(lambda s: str(s)[2:-1])
    return df


def print_vals(df, col_name):
    print(col_name)
    temp_arr = []
    for s in df[col_name]:
        if str(s) not in temp_arr:
            temp_arr.append(str(s))
    print(temp_arr)
    print("len = " + str(len(temp_arr)))


def df_to_dataset(dataframe, shuffle=True, batch_size=16, target="target", only_feature=False, target_cols=None):
    df = dataframe.copy()
    if only_feature:
        tar_df = df[target_cols].copy()
        df = df.drop(columns=target_cols)

        df = {key: value[:,tf.newaxis] for key, value in dataframe.items()}
        tar_df2 = {key: value[:,tf.newaxis] for key, value in tar_df.items()}
        ds = tf.data.Dataset.from_tensor_slices((dict(df), dict(tar_df2)))
    else:
        labels = df.pop(target)
        df = {key: value[:,tf.newaxis] for key, value in dataframe.items()}
        ds = tf.data.Dataset.from_tensor_slices((dict(df), labels))
        if shuffle:
            ds = ds.shuffle(buffer_size=len(dataframe))
    ds = ds.batch(batch_size)
    ds = ds.prefetch(batch_size)
    
    return ds


def get_normalization_layer(name, dataset, only_feature=False):
    # Create a Normalization layer for the feature.
    normalizer = layers.Normalization(axis=None)

    if only_feature:
        feature_ds = dataset.copy()
    else:
        # Prepare a Dataset that only yields the feature.
        feature_ds = dataset.map(lambda x, y: x[name])

    # Learn the statistics of the data.
    normalizer.adapt(feature_ds)

    return normalizer


def get_category_encoding_layer(name, dataset, dtype, max_tokens=None, only_feature=False):
    # Create a layer that turns strings into integer indices.
    if dtype == 'string':
        index = layers.StringLookup(max_tokens=max_tokens)
    # Otherwise, create a layer that turns integer values into integer indices.
    else:
        index = layers.IntegerLookup(max_tokens=max_tokens)

    if only_feature:
        feature_ds = dataset.map(lambda x: x[name])
    else:
        # Prepare a `tf.data.Dataset` that only yields the feature.
        feature_ds = dataset.map(lambda x, y: x[name])

    # Learn the set of possible values and assign them a fixed integer index.
    index.adapt(feature_ds)

    # Encode the integer indices.
    encoder = layers.CategoryEncoding(num_tokens=index.vocabulary_size())

    # Apply multi-hot encoding to the indices. The lambda function captures the
    # layer, so you can use them, or include them in the Keras Functional model later.
    return lambda feature: encoder(index(feature))


def num_to_cls(n):
    return data_list.cls_list[n]


def max_elements(lst, n):
    max_vals = []
    max_index = []


    lst = list(lst)
    lst2 = lst.copy()

    for i in range(0, n):
        v = max(lst)
        max_vals.append(v)
        max_index.append(lst2.index(v))
        lst.remove(v)
    return max_vals, max_index


def get_cat_prediction(model, sample):
    input_dict = {name: tf.convert_to_tensor([value]) for name, value in sample.items()}
    return model.predict(input_dict)


def get_attr_prediction(model, sample, column_names):
    temp = pd.DataFrame(0, index = np.arange(1,2), columns=column_names)
    for v in sample:
        temp[v][1] = 1
    return int(round(float(model.predict(temp)[0][0])))

def get_all_attr_predictions(attr_models, char_dict, column_names):
    sample = [char_dict['cls'], char_dict['race']]
    preds = []
    for m in attr_models:
        preds.append(get_attr_prediction(m, sample, column_names))
    return preds


def create_cat_model(input_df, cat_input_cols, numeric_input_cols, target_col, target_data_list=None, batch_size=0):
    all_cols = numeric_input_cols + cat_input_cols
    all_cols.append(target_col)
    df = input_df[all_cols].copy()
    df['target'] = [target_data_list.index(i) for i in df[target_col]]   
    df = df.drop(columns=[target_col])

    train, val, test = np.split(df.sample(frac=1), [int(0.8*len(df)), int(0.9*len(df))])

    if batch_size == 0:
        batch_size = int(len(train.index))

    train_ds = df_to_dataset(train, batch_size=batch_size)
    val_ds = df_to_dataset(val, shuffle=False, batch_size=batch_size)
    test_ds = df_to_dataset(test, shuffle=False, batch_size=batch_size)

    all_inputs = []
    encoded_features = []

    # Numerical features.
    for header in numeric_input_cols:
        numeric_col = tf.keras.Input(shape=(1,), name=header)
        normalization_layer = get_normalization_layer(header, train_ds)
        encoded_numeric_col = normalization_layer(numeric_col)
        all_inputs.append(numeric_col)
        encoded_features.append(encoded_numeric_col)

    for header in cat_input_cols:
        categorical_col = tf.keras.Input(shape=(1,), name=header, dtype='string')
        encoding_layer = get_category_encoding_layer(name=header,
                                                    dataset=train_ds,
                                                    dtype='string')
        encoded_categorical_col = encoding_layer(categorical_col)
        all_inputs.append(categorical_col)
        encoded_features.append(encoded_categorical_col)

    if len(cat_input_cols) + len(numeric_input_cols) > 1:
        all_features = tf.keras.layers.concatenate(encoded_features)
    else:
        all_features = encoded_features[0]

    s1 = int(tf.keras.backend.int_shape(all_features)[1]) * 2 / 3 + int(len(target_data_list))
    x1 = tf.keras.layers.Dense(s1, activation="elu")(all_features)
    s2 = (s1 * 2 / 3 + int(len(target_data_list)))
    x2 = tf.keras.layers.Dense(s2, activation="elu")(x1)
    output = tf.keras.layers.Dense(int(len(target_data_list)))(x2)

    model = tf.keras.Model(all_inputs, output)

    model.compile(optimizer='adam',
            loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
            metrics=["binary_crossentropy"])


    model.fit(train_ds, epochs=16, validation_data=val_ds)
    loss, accuracy = model.evaluate(test_ds)
    
    if verbose:
        print("Accuracy", accuracy)
    
    if debug_mode:
        predictions = model.predict(test_ds)
        print(test.iloc[0])
        print(predictions[0])
        print(target_data_list[(int(np.argmax(predictions[0])))])

        max_vals, max_idx = max_elements(predictions[0], 3)
        print(max_vals)
        print(max_idx)

    return model


def create_attr_model(input_df, cat_input_cols, numeric_input_cols, target_col):
    print("Training " + str(target_col) + "_model...")
    all_cols = numeric_input_cols + cat_input_cols
    all_cols.append(target_col)
    df = input_df[all_cols].copy()

    df = df.dropna()

    max_val = df[target_col].max()
    min_val = df[target_col].min()

    df = pd.get_dummies(df, columns=cat_input_cols, prefix="", prefix_sep="")

    column_names = list(df.columns)
    column_names.remove(target_col)

    train_dataset = df.sample(frac=0.85, random_state=0)
    test_dataset = df.drop(train_dataset.index)

    train_features = train_dataset.copy()
    test_features = test_dataset.copy()

    train_labels = train_features.pop(target_col)
    test_labels = test_features.pop(target_col)


    s1 = int(train_dataset.shape[1]) * 2 / 3 + 1
    model = tf.keras.Sequential([tf.keras.layers.Dense(s1, activation="relu"), tf.keras.layers.Dense(1)])

    model.compile(loss='mean_absolute_error',
            optimizer=tf.keras.optimizers.Adam(0.1))

    history = model.fit(
        train_features,
        train_labels,
        epochs=100,
        # Suppress logging.
        verbose=0,
        # Calculate validation results on 15% of the training data.
        validation_split = 0.15)

    if debug_mode:
        print(max_val)
        print(min_val)
        hist = pd.DataFrame(history.history)
        hist['epoch'] = history.epoch
        print(hist.tail())

        print(model.predict(train_features[:10]))

        test_results = model.evaluate(test_features, test_labels)
        print(test_results)

    return model, column_names


# training
def train_models(dataframe_in, item_dataframe_in, data_list_in, ver, deb, tst):
    global verbose
    global debug_mode
    global testing_mode

    verbose = ver 
    debug_mode = deb
    testing_mode = tst
    
    global data_list
    data_list = data_list_in
    dataframe_in = dataframe_in.drop(dataframe_in[dataframe_in.cls == b'apothecary'].index)
    dataframe_in = dataframe_in.drop(dataframe_in[dataframe_in.level != 1].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.cls == b'apothecary'].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == 'Being Worn/equipped'].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Scrap Of Paper With Uninteligible Writing On It"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Of Hemp Rope"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Priest Pack"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Heward's Handy Haversack"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Hairpin Of Color Changing"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Strapped To Backpack"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Including A Hood"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Gallons Water"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Skateboarding Helmet"].index)
    item_dataframe_in = item_dataframe_in.drop(item_dataframe_in[item_dataframe_in.item == "Charges"].index)




    dataframe = dataframe_in[['cls', 'background', 'race', 'alignment', 'str', 'dex', 'con', 'int', 'wis', 'cha']].copy()

    item_df = item_dataframe_in[['cls', 'background', 'race', 'alignment', 'str', 'dex', 'con', 'int', 'wis', 'cha', 'item']].copy()

    print(dataframe.head())
    print(item_df.head())

    str_cols = ["cls", "background", "race", "alignment"]
    dataframe = trim_strings(dataframe, str_cols)
    item_df = trim_strings(item_df, str_cols)
    item_df['item'] = item_df['item'].apply(lambda s: s.lower())
    print(item_df.head())

    if debug_mode and testing_mode:
        print_vals(dataframe, "cls")
        dataframe['target'] = [data_list.cls_list.index(i) for i in dataframe["cls"]]
        dataframe = dataframe.drop(columns=["cls"])
        

        train, val, test = np.split(dataframe.sample(frac=1), [int(0.8*len(dataframe)), int(0.9*len(dataframe))])

        if verbose:
            print(len(train), 'training examples')
            print(len(val), 'validation examples')
            print(len(test), 'test examples')
            print()

    # cls prediction
    # data_list.cls_list.index(test_df["cls"])
    if debug_mode and testing_mode:
        test_df = train.copy()

        test_ds = df_to_dataset(test_df, batch_size=16, target="target")
    
        [(train_features, label_batch)] = test_ds.take(1)
        print('Every feature:', list(train_features.keys()))
        print('A batch of races:', train_features['race'])
        print('A batch of targets:', label_batch )
        print()
        print()

        ac_count_col = train_features['ac']
        layer = get_normalization_layer('ac', test_ds)
        print("AC")
        print(layer(ac_count_col))

        print()
        print()

        print("RACE")
        test_race_col = train_features['race']
        test_race_layer = get_category_encoding_layer(name='race',
                                                    dataset=test_ds,
                                                    dtype='string')
        print(test_race_layer(test_race_col))

    if debug_mode and testing_mode:
        train_ds = df_to_dataset(train, batch_size=int(len(train.index)))
        val_ds = df_to_dataset(val, shuffle=False, batch_size=int(len(val.index)))
        test_ds = df_to_dataset(test, shuffle=False, batch_size=int(len(test.index)))

        all_inputs = []
        encoded_features = []

        # Numerical features.
        numerical_cols = ['ac']
        for header in numerical_cols:
            numeric_col = tf.keras.Input(shape=(1,), name=header)
            normalization_layer = get_normalization_layer(header, train_ds)
            encoded_numeric_col = normalization_layer(numeric_col)
            all_inputs.append(numeric_col)
            encoded_features.append(encoded_numeric_col)

        categorical_cols = ['background', 'race', 'alignment']

        for header in categorical_cols:
            categorical_col = tf.keras.Input(shape=(1,), name=header, dtype='string')
            encoding_layer = get_category_encoding_layer(name=header,
                                                        dataset=train_ds,
                                                        dtype='string',
                                                        max_tokens=5)
            encoded_categorical_col = encoding_layer(categorical_col)
            all_inputs.append(categorical_col)
            encoded_features.append(encoded_categorical_col)

        all_features = tf.keras.layers.concatenate(encoded_features)
        x = tf.keras.layers.Dense(144, activation="elu")(all_features)
        output = tf.keras.layers.Dense(12)(x)

        model = tf.keras.Model(all_inputs, output)



        model.compile(optimizer='adam',
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
              metrics=["binary_crossentropy"])

        model.fit(train_ds, epochs=10, validation_data=val_ds)
        loss, accuracy = model.evaluate(test_ds)
        print("Accuracy", accuracy)

        model.save('debug_classifier')
        reloaded_model = tf.keras.models.load_model('debug_classifier')

        #should output paladin (6)
        sample = {
            'background': "bounty hunter",
            'race': 'mountain dwarf',
            "alignment": "lawful neutral",
            "ac": 12
        }

        input_dict = {name: tf.convert_to_tensor([value]) for name, value in sample.items()}
        predictions = reloaded_model.predict(test_ds)
        print(test.iloc[0])
        print(predictions[0])
        print(num_to_cls(int(np.argmax(predictions[0]))))

        pred = reloaded_model.predict(input_dict)
        print(pred)

    if debug_mode and testing_mode:
        model = create_cat_model(dataframe, ['background', 'race', 'alignment'], [], 'cls', target_data_list=data_list.cls_list)

        sample = {
            'background': '',
            'race': 'mountain dwarf',
            'alignment': ''
        }

        input_dict = {name: tf.convert_to_tensor([value]) for name, value in sample.items()}

        pred = model.predict(input_dict)
        print(pred)
    
    # Make changes to models here
    align_model = create_cat_model(dataframe, ['cls'], [], 'alignment', target_data_list=data_list.alignment_list)
    race_model = create_cat_model(dataframe, ['cls', 'alignment'], [], 'race', target_data_list=data_list.race_list)
    background_model = create_cat_model(dataframe, ['cls', 'alignment', 'race'], [], 'background', target_data_list=data_list.background_list)
    
    str_model, col_names = create_attr_model(dataframe, ['cls', 'race'], [], 'str')
    dex_model, t = create_attr_model(dataframe, ['cls', 'race'], [], 'dex')
    con_model, t = create_attr_model(dataframe, ['cls', 'race'], [], 'con')
    int_model, t = create_attr_model(dataframe, ['cls', 'race'], [], 'int')
    wis_model, t = create_attr_model(dataframe, ['cls', 'race'], [], 'wis')
    cha_model, t = create_attr_model(dataframe, ['cls', 'race'], [], 'cha')

    attr_models = [str_model, dex_model, con_model, int_model, wis_model, cha_model]

    item_model = create_cat_model(item_df, ['cls', 'background'], ['str', 'dex', 'con'], 'item',
                            target_data_list=data_list.inventory_list)


    if debug_mode:
        sample = {
            'cls' : "paladin",
            "background": "bounty hunter",
            "race": "mountain dwarf"
        }

        print(get_all_attr_predictions(attr_models, sample, col_names))

    if debug_mode:
        sample = {
            'cls' : "wizard",
            "background": "mercenary veteran",
            "race": "tiefling",
            "str": 10,
            "dex": 14, 
            "con": 13
        }

        print(get_cat_prediction(item_model, sample))


    return align_model, race_model, background_model, attr_models, item_model, col_names


