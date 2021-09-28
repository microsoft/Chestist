import os
import numpy as np
import torch
import torch.nn as nn
import torch.backends.cudnn as cudnn
import torchvision.transforms as transforms
from torch.utils.data import DataLoader
from sklearn.metrics import roc_auc_score
import torchvision

class CNNModel (nn.Module):

    def __init__(self, classCount, isTrained):
	
        super(CNNModel, self).__init__()
		
        self.cnnmodel = torchvision.models.densenet121(pretrained=isTrained)

        kernelCount = self.cnnmodel.classifier.in_features
		
        self.cnnmodel.classifier = nn.Sequential(nn.Linear(kernelCount, classCount), nn.Sigmoid())

    def forward(self, x):
        x = self.cnnmodel(x)
        return x


