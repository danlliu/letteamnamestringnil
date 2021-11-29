import sys
import random

import pandas as pd
import numpy as np
from tqdm.auto import tqdm

import tensorflow as tf
from tensorflow.keras import layers


import CharacterData as cd

debug_mode = False
verbose = False

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


def df_to_dataset(dataframe, shuffle=True, batch_size=16, target="target"):
    df = dataframe.copy()
    labels = df.pop(target)
    df = {key: value[:,tf.newaxis] for key, value in dataframe.items()}
    ds = tf.data.Dataset.from_tensor_slices((dict(df), labels))
    if shuffle:
        ds = ds.shuffle(buffer_size=len(dataframe))
    ds = ds.batch(batch_size)
    ds = ds.prefetch(batch_size)
    return ds


def get_normalization_layer(name, dataset):
    # Create a Normalization layer for the feature.
    normalizer = layers.Normalization(axis=None)

    # Prepare a Dataset that only yields the feature.
    feature_ds = dataset.map(lambda x, y: x[name])

    # Learn the statistics of the data.
    normalizer.adapt(feature_ds)

    return normalizer


def get_category_encoding_layer(name, dataset, dtype, max_tokens=None):
    # Create a layer that turns strings into integer indices.
    if dtype == 'string':
        index = layers.StringLookup(max_tokens=max_tokens)
    # Otherwise, create a layer that turns integer values into integer indices.
    else:
        index = layers.IntegerLookup(max_tokens=max_tokens)

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


# training
def train_models(dataframe, data_list_in, ver, deb):
    global verbose
    global debug_mode

    verbose = ver 
    debug_mode = deb
    
    global data_list
    data_list = data_list_in
    print_vals(dataframe, "cls")
    dataframe = dataframe.drop(dataframe[dataframe.cls == b'apothecary'].index)
    dataframe = dataframe.drop(dataframe[dataframe.level != 1].index)
    print_vals(dataframe, "cls")
    print_vals(dataframe, "race")

    dataframe = dataframe[['cls', 'background', 'race', 'alignment', 'ac']].copy()

    if debug_mode:
        str_cols = ["cls", "background", "race", "alignment"]
        dataframe = trim_strings(dataframe, str_cols)
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
    if debug_mode:
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

    if debug_mode:
        batch_size = 256
        
        train_ds = df_to_dataset(train, batch_size=len(train.index))
        val_ds = df_to_dataset(val, shuffle=False, batch_size=len(val.index))
        test_ds = df_to_dataset(test, shuffle=False, batch_size=len(test.index))

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
        predictions = model.predict(test_ds)
        print(test.iloc[0])
        print(predictions[0])
        print(num_to_cls(int(np.argmax(predictions[0]))))

        pred = model.predict(input_dict)
        print(pred)



    

    

    