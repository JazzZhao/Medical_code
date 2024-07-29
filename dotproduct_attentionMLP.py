import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import tensorflow_addons as tfa
import matplotlib.pyplot as plt

class PatchExtract(layers.Layer): #提取patch
    def __init__(self, patch_size, **kwargs):
        super(PatchExtract, self).__init__(**kwargs)
        self.patch_size = patch_size

    def call(self, images):
        batch_size = tf.shape(images)[0]
        patches = tf.image.extract_patches(
            images=images,
            sizes=(1, self.patch_size, self.patch_size, 1),
            strides=(1, self.patch_size, self.patch_size, 1),
            rates=(1, 1, 1, 1),
            padding="VALID",
        )
        patch_dim = patches.shape[-1]
        patch_num = patches.shape[1]
        return tf.reshape(patches, (batch_size, patch_num * patch_num, patch_dim))


class PatchEmbedding(layers.Layer): #patch转化为地位矩阵embedding
    def __init__(self, num_patch, embed_dim, **kwargs):
        super(PatchEmbedding, self).__init__(**kwargs)
        self.num_patch = num_patch
        self.proj = layers.Dense(embed_dim)
        self.pos_embed = layers.Embedding(input_dim=num_patch, output_dim=embed_dim)

    def call(self, patch):
        pos = tf.range(start=0, limit=self.num_patch, delta=1)
        return self.proj(patch) + self.pos_embed(pos)
    
    
def dotproduct_attention(
    x, dim, num_heads, dim_coefficient=4, attention_dropout=0, projection_dropout=0
): #点积计算attention值,输入为patch批次矩阵（（2*2），数量，通道数），embedding_dim，
    #超参数num_heads（保证embedding_num和num_head是倍数关系）
    #和常规参数embedding系数、attention单元的dropout率（去掉一些运算过程中产生的参数，设为0是不去除）和映射层的dropout
    _, num_patch, channel = x.shape #获取patch数量和通道个数
    assert dim % num_heads == 0 #确保embedding_num和num_head是倍数关系
    num_heads = num_heads * dim_coefficient #

    x = layers.Dense(dim * dim_coefficient)(x) #定义一个网络层，执行的操作是func(input*kernel)+bias,这里的*是计算点积，
                                               #计算patches与embedding的点积并赋值给patches
    x = tf.reshape(
        x, shape=(-1, num_patch, num_heads, dim * dim_coefficient // num_heads)
    )  #将patches重新还原为原来的维度
    x = tf.transpose(x, perm=[0, 2, 1, 3]) #求pathes的转置（高和列），并将转置的矩阵赋值给patches
    attn = layers.Dense(dim // dim_coefficient)(x) #网络层，将转置后的patches计算点积产生attention向量
    attn = layers.Softmax(axis=2)(attn) #softmax函数，计算attention向量
    attn = attn / (1e-9 + tf.reduce_sum(attn, axis=-1, keepdims=True)) #计算attention值，tf.reduce_sum是按维度求和，
                                                                        #通过attention向量计算attention值
    attn = layers.Dropout(attention_dropout)(attn) #去除中间过程产生的参数
    x = layers.Dense(dim * dim_coefficient // num_heads)(attn) #计算patche和attention值的点积
    x = tf.transpose(x, perm=[0, 2, 1, 3]) #patches高和列转置
    x = tf.reshape(x, [-1, num_patch, dim * dim_coefficient]) #复原patches为原来的维度
    x = layers.Dense(dim)(x) #计算dim与patches的点积
    x = layers.Dropout(projection_dropout)(x) #去除中间过程产生的参数
    return x

def mlp(x, embedding_dim, mlp_dim, drop_rate=0.2): #喂给MLP
    x = layers.Dense(mlp_dim, activation=tf.nn.gelu)(x)
    x = layers.Dropout(drop_rate)(x)
    x = layers.Dense(embedding_dim)(x)
    x = layers.Dropout(drop_rate)(x)
    return x

def transformer_encoder(
    x,
    embedding_dim,
    mlp_dim,
    num_heads,
    dim_coefficient,
    attention_dropout,
    projection_dropout,
    attention_type="dotproduct_attention",
): #encoder步骤
    residual_1 = x
    x = layers.LayerNormalization(epsilon=1e-5)(x)
    if attention_type == "dotproduct_attention":
        x = dotproduct_attention(
            x,
            embedding_dim,
            num_heads,
            dim_coefficient,
            attention_dropout,
            projection_dropout,
        )
    elif attention_type == "self_attention":
        x = layers.MultiHeadAttention(
            num_heads=num_heads, key_dim=embedding_dim, dropout=attention_dropout
        )(x, x)
    x = layers.add([x, residual_1])
    residual_2 = x
    x = layers.LayerNormalization(epsilon=1e-5)(x)
    x = mlp(x, embedding_dim, mlp_dim)
    x = layers.add([x, residual_2])
    return x

def get_model(attention_type="dotproduct_attention"):
    inputs = layers.Input(shape=input_shape)
    x = data_augmentation(inputs)
    x = PatchExtract(patch_size)(x)
    x = PatchEmbedding(num_patches, embedding_dim)(x)
    for _ in range(num_transformer_blocks):
        x = transformer_encoder(
            x,
            embedding_dim,
            mlp_dim,
            num_heads,
            dim_coefficient,
            attention_dropout,
            projection_dropout,
            attention_type,
        )

    x = layers.GlobalAvgPool1D()(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)
    model = keras.Model(inputs=inputs, outputs=outputs)
    return model


#加载数据
num_classes = 100
input_shape = (32, 32, 3)

(x_train, y_train), (x_test, y_test) = keras.datasets.cifar100.load_data()
y_train = keras.utils.to_categorical(y_train, num_classes)
y_test = keras.utils.to_categorical(y_test, num_classes)
print(f"x_train shape: {x_train.shape} - y_train shape: {y_train.shape}")
print(f"x_test shape: {x_test.shape} - y_test shape: {y_test.shape}")

#设置超参数
weight_decay = 0.0001
learning_rate = 0.001
label_smoothing = 0.1
validation_split = 0.2
batch_size = 128
num_epochs = 50
patch_size = 2  # 从原图提取patch的窗口大小2*2
num_patches = (input_shape[0] // patch_size) ** 2  # patch数量
embedding_dim = 64  # 隐藏单元数量
mlp_dim = 64
dim_coefficient = 4
num_heads = 4
attention_dropout = 0.2
projection_dropout = 0.2
num_transformer_blocks = 8  #transformer层的重复次数

print(f"Patch size: {patch_size} X {patch_size} = {patch_size ** 2} ")
print(f"Patches per image: {num_patches}")


#数据增强
data_augmentation = keras.Sequential(
    [
        layers.Normalization(),
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(factor=0.1),
        layers.RandomContrast(factor=0.1),
        layers.RandomZoom(height_factor=0.2, width_factor=0.2),
    ],
    name="data_augmentation",
)
#计算训练集的平均值和方差，便于正则化训练集
data_augmentation.layers[0].adapt(x_train)

#开始调用模型
model = get_model(attention_type="dotproduct_attention")

model.compile(
    loss=keras.losses.CategoricalCrossentropy(label_smoothing=label_smoothing),
    optimizer=tfa.optimizers.AdamW(
        learning_rate=learning_rate, weight_decay=weight_decay
    ),
    metrics=[
        keras.metrics.CategoricalAccuracy(name="accuracy"),
        keras.metrics.TopKCategoricalAccuracy(5, name="top-5-accuracy"),
    ],
)

history = model.fit(
    x_train,
    y_train,
    batch_size=batch_size,
    epochs=num_epochs,
    validation_split=validation_split,
)


#画混淆矩阵
from sklearn.metrics import confusion_matrix
import itertools
plt.rcParams['figure.figsize'] = [12,12]

def plot_confusion_matrix(cm, classes,
                          normalize=False,
                          title='Confusion matrix',
                          cmap=plt.cm.Blues):

    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        print("Normalized confusion matrix")
    else:
        print('Confusion matrix, without normalization')
    print(cm)
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks[0::2], classes[0::2], rotation=0)
    plt.yticks(tick_marks[0::2], classes[0::2])
    '''
    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, format(cm[i, j], fmt),
               horizontalalignment="center",
               color="white" if cm[i, j] > thresh else "black")
    '''

    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    plt.savefig('./picture/confusion_matrix.jpeg',dpi=1200,bbox_inches='tight')
    plt.show()

p_test = model.predict(x_test).argmax(axis=1)
cm = confusion_matrix(y_test.argmax(axis=1), p_test)
plot_confusion_matrix(cm, list(range(100)))

#画损失函数
plt.plot(history.history["loss"], label="train_loss")
plt.plot(history.history["val_loss"], label="val_loss")
plt.xlabel("Epochs")
plt.ylabel("Loss")
plt.title("Train and Validation Losses Over Epochs", fontsize=14)
plt.legend()
plt.grid()
plt.savefig('./picture/loss_function.jpeg',dpi=800,bbox_inches='tight')
plt.show()
