import numpy as np
import pandas as pd
import os
import shutil
import cv2
import matplotlib.pyplot as plt
import seaborn as sns
import azureml.core
from azureml.core import Workspace, Datastore, Dataset
from azureml.core.authentication import InteractiveLoginAuthentication
# #%matplotlib inline
from TrainerTester import TrainerTester
import random
import time
import torch
from torch import nn
from torch.utils.data import DataLoader
import torch
from torchvision import transforms
from PIL import Image
from sklearn.metrics.ranking import roc_auc_score


# %env TENANT_ID=
# %env SUBSCRIPTION_ID=
# %env RESOURCE_GROUP=
# %env WORKSPACE_NAME=
# %env DATASTORE_NAME=
# %env DATASET_NAME=
# %env DATASET_NAME_CSV=
# %env IMAGES_SUBFOLDER=

def main ():
    runTrain()
    #return true


def runTrain():
    #Do some training here
    
    CNNMODEL='CNNModel'
    timestampTime = time.strftime("%H%M%S")
    timestampDate = time.strftime("%d%m%Y")
    timestampLaunch = timestampDate + '-' + timestampTime
    
    #-------------------- SETTINGS: AML WORKSPACE AND DATASTORE
    interactive_auth = InteractiveLoginAuthentication(tenant_id=os.environ['TENANT_ID'])
    ws = Workspace(
            subscription_id=os.environ['SUBSCRIPTION_ID'],
            resource_group=os.environ["RESOURCE_GROUP"],
            workspace_name=os.environ['WORKSPACE_NAME'],
            auth=interactive_auth
        )
    datastore = Datastore.get(ws, datastore_name=os.environ['DATASTORE_NAME'])
    
    

    #-------------------- SETTINGS: MOUNTING THE DATASET TO MAKE IT AVAILABLE
    chestist_data = Dataset.get_by_name(ws,os.environ['DATASET_NAME'])
    mountPoint = chestist_data.mount()
    mountPoint.start()
    mountFolder = mountPoint.mount_point
    pathDirData=mountFolder
    #pathDirData=files
    
    chestist_data_csv = Dataset.get_by_name(ws,os.environ['DATASET_NAME_CSV'])
    mountPoint = chestist_data.mount()
    mountPoint.start()
    mountFolder = mountPoint.mount_point
    csv=mountFolder
    #pathDirData=files
    
    #-------------------- SPLIT DATA
    patient_data = pd.read_csv(f"{csv}/Data_Entry_2017_v2020 (1).csv", header=0)
    patient_data = patient_data.dropna()
    lenDataset=int(patient_data.shape[0])
    indexDataset=list(patient_data.index)
    
    #pathFileTrain=[] #Path for images to train the model
    #pathFileVal=[]#Path for validation set
    
    trainPercentage=(0.02*lenDataset)/100
    devPercentage=(0.01*lenDataset)/100
    valPercentage=(0.01*lenDataset)/100

    train=random.sample(range(0, 112120), int(trainPercentage))
    indexDataset = [i for i in indexDataset if i not in train]

    dev=random.sample(range(0, 112120), int(devPercentage))
    indexDataset = [i for i in indexDataset if i not in dev]


    val=random.sample(range(0, 112120), int(valPercentage))
    indexDataset = [i for i in indexDataset if i not in val]
    
    #patient_data
    train_dataframe = patient_data.iloc[train, :]
    dev_dataframe = patient_data.iloc[dev, :]
    val_dataframe = patient_data.iloc[val, :]
    
    trainListImages=train_dataframe['Image Index'].tolist()
    #patient_data.loc.values.flatten().tolist()
    #print(trainListImages)
    listImagePathsTrain=[]
    for i,image in enumerate(trainListImages):
                trainListImages[i]=mountFolder+"/"+image
                listImagePathsTrain.append(trainListImages[i])
                
    valListImages=val_dataframe['Image Index'].tolist()
    #patient_data.loc.values.flatten().tolist()
    #print(trainListImages)
    listImagePathsVal=[]
    for i,image in enumerate(valListImages):
                valListImages[i]=mountFolder+"/"+image
                listImagePathsVal.append(valListImages[i])

    devListImages=dev_dataframe['Image Index'].tolist()
    #patient_data.loc.values.flatten().tolist()
    #print(trainListImages)
    listImagesPathDev=[]
    for i,image in enumerate(valListImages):
                devListImages[i]=mountFolder+"/"+image
                listImagesPathDev.append(devListImages[i])

    #listImageLabels=labelList
    #listImagePathsVal

    #pathFileTrain=train
    #pathFileVal=val

    
    
    #---- Neural network parameters: type of the network, is it pre-trained on imagenet? , number of classes
    nnArchitecture = CNNMODEL
    nnIsTrained = True
    nnClassCount = 14 #Because it has 14 different labels to be detected
    
    #---- Training settings: batch size, maximum number of epochs
    trBatchSize = 16 #Might change! this is for the first iteration
    trMaxEpoch = 1 #Same here, this could change
    
    #---- Parameters related to image transforms: size of the down-scaled image, cropped image
    imgtransResize = 256
    imgtransCrop = 224
      
    #Path to save the trained model
    pathModel = 'm-' + timestampLaunch + '.pth.tar'
    
    print ('Architecture Selected to train = ', nnArchitecture)
    print ('pathDirData',pathDirData)
    print ('listDir',os.listdir(pathDirData))
    TrainerTester.trainer(pathDirData, listImagePathsTrain, listImagePathsVal,listImagesPathDev, nnArchitecture, nnIsTrained, nnClassCount, trBatchSize, trMaxEpoch, imgtransResize, imgtransCrop, timestampLaunch, None)
    
    
    print ('Testing the trained model...')
    TrainerTester.tester(pathDirData, listImagesPathDev, pathModel, nnArchitecture, nnClassCount, nnIsTrained, trBatchSize, imgtransResize, imgtransCrop, timestampLaunch)


def runTest():
    #Do some model testing here
    
    timestampTime = time.strftime("%H%M%S")
    timestampDate = time.strftime("%d%m%Y")
    timestampLaunch = timestampDate + '-' + timestampTime
    
    #-------------------- SETTINGS: AML WORKSPACE AND DATASTORE
    interactive_auth = InteractiveLoginAuthentication(tenant_id=TENANT_ID)
    ws = Workspace(
            subscription_id=SUBSCRIPTION_ID,
            resource_group=RESOURCE_GROUP,
            workspace_name=WORKSPACE_NAME,
            auth=interactive_auth
        )
    datastore = Datastore.get(ws, datastore_name=DATASTORE_NAME)
    
    

    #-------------------- SETTINGS: MOUNTING THE DATASET TO MAKE IT AVAILABLE
    chestist_data = Dataset.get_by_name(ws,DATASET_NAME)
    mountPoint = chestist_data.mount()
    mountPoint.start()
    mountFolder = mountPoint.mount_point
    files=os.listdir(mountFolder+os.environ['IMAGES_SUBFOLDER']) #Need to generalize for the whole dataset
    
    pathDirData = files
    pathFileTest = '' # Pat of images for test
    nnArchitecture = 'CNNModel'
    nnIsTrained = True
    nnClassCount = 14
    trBatchSize = 16
    imgtransResize = 256
    imgtransCrop = 224
    
    
    pathModel = 'm-' + timestampLaunch + '.pth.tar' #path of the model to test, needs to change
    
    #timestampLaunch = ''
    
    TrainerTester.tester(pathDirData, pathFileTest, pathModel, nnArchitecture, nnClassCount, nnIsTrained, trBatchSize, imgtransResize, imgtransCrop, timestampLaunch)


