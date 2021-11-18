import sys

import pandas as pd
import numpy as np
from tqdm.auto import tqdm

import tensorflow as tf
from tensorflow.keras import layers

import CharacterData as cd

debug_mode = False
verbose = False

data_list = cd.DataLists()

def df_to_dataset(dataframe, shuffle=True, batch_size=16, target="target"):
    df = dataframe.copy()
    labels = df.pop(target)
    df = {key: value[:,tf.newaxis] for key, value in dataframe.items()}
    #rt = tf.ragged.constant(df)
    #ds = tf.data.Dataset.from_tensor_slices(rt)
    ds = tf.data.Dataset.from_tensor_slices((dict(df), labels))
    if shuffle:
        ds = ds.shuffle(buffer_size=len(dataframe))
    ds = ds.batch(batch_size)
    ds = ds.prefetch(batch_size)
    return ds


def train_models(dataframe, data_list_in, ver, deb):
    global verbose
    global debug_mode

    verbose = ver 
    debug_mode = deb
    
    global data_list
    data_list = data_list_in

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
        str_cols = ["cls", "background", "race", "alignment"]
        for tag in str_cols:
            test_df[tag] = test_df[tag].apply(lambda s: str(s)[2:-1])
        test_df['target'] = [data_list.cls_list.index(i) for i in test_df["cls"]]
        test_df = test_df.drop(columns=["cls"])

        test_ds = df_to_dataset(test_df, batch_size=16, target="target")
    
        [(train_features, label_batch)] = test_ds.take(1)
        print('Every feature:', list(train_features.keys()))
        print('A batch of races:', train_features['race'])
        print('A batch of targets:', label_batch )