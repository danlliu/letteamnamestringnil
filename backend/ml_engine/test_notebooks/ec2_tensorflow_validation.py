#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np

# Make numpy values easier to read.
np.set_printoptions(precision=3, suppress=True)

import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras.layers.experimental import preprocessing


# In[2]:

print("")
print("TENSORFLOW VALIDATION TEST")
print("TensorFlow version:", tf.__version__)
print("")


# In[3]:


mnist = tf.keras.datasets.mnist

(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train = x_train[:1000]
y_train = y_train[:1000]
x_test = x_test[:1000]
y_test = y_test[:1000]
x_train, x_test = x_train / 255.0, x_test / 255.0


# In[4]:


model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10)
])


# In[5]:


predictions = model(x_train[:1]).numpy()

print("")
print("predictions:")
print(predictions)
print("")

# In[6]:


loss_fn = tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True)


# In[7]:


print("loss_fn:")
print(loss_fn(y_train[:1], predictions).numpy())
print("")


# In[8]:


model.compile(optimizer='adam',
              loss=loss_fn,
              metrics=['accuracy'])


# In[9]:


model.fit(x_train, y_train, epochs=5)


# In[10]:

print("")
print("model evaluation:")
model.evaluate(x_test,  y_test, verbose=2)
print("")


# In[11]:


probability_model = tf.keras.Sequential([
  model,
  tf.keras.layers.Softmax()
])


# In[12]:


print("probability_model:")
print(probability_model(x_test[:5]))


# In[ ]:




