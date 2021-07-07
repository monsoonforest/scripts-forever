#!/usr/bin/env python

# atmos.py

import os, sys
#import re
#from datetime import datetime, timedelta
import numpy as np
#import scipy as sp
#import matplotlib.pyplot as plt
#from mpl_toolkits.basemap import Basemap
#from matplotlib import mlab
from lidar import LidarDataset

__all__ = ['AtmosProfile',
        'SingleProfile', 
        'interp_p_t_profile', 
        'interp_single_profile',
        'calc_betam',
        'prof_midlatitude_summer', 'prof_midlatitude_winter',
        'prof_subarctic_summer', 'prof_subarctic_winter', 'prof_tropical',
        'prof_us1976']


class AtmosProfile(object):
    def __init__(self, fname):
        data = np.loadtxt(fname, dtype=[('height', 'f4'), ('pressure', 'f4'), ('temperature', 'f4')], skiprows=1, delimiter=',')
        self.height = data['height']
        self.pressure = data['pressure']
        self.temperature = data['temperature']
        self._len = len(self.height)
        self.name = os.path.basename(fname).rstrip('.profile')

    def __len__(self):
        return self._len

class SingleProfile(object):
    def __init__(self, fname):
        data = np.loadtxt(fname, dtype=[('height', 'f4'), ('value','f4')], skiprows=1, delimiter=',')
        self.height = data['height']
        self.value = data['value']
        self._len = len(self.height)
        self.name = os.path.basename(fname).rstrip('.profile')

    def __len__(self):
        return self._len

def interp_single_profile(prof, data, elev_angle=90.0):
    """interp single field profile to match lidar data.
    prof: an SingleProfile object.
    data: a LidarDataset object, or simply an array of distance.
    elev_angle: optional. if is None, try to use data.vars['elev_angle'].
    return interped_values
    """
    if type(data) is LidarDataset:
        height = data['distance'] * np.sin(np.deg2rad(elev_angle))
    else:
        height = data * np.sin(np.deg2rad(elev_angle))
    res = np.interp(height, prof.height, prof.value)
    return res

def interp_p_t_profile(prof, data, elev_angle=90.0):
    """interp pressure and temperature profile to match lidar data.
    prof: an AtmosProfile object.
    data: a LidarDataset object, or simply an array of distance.
    elev_angle: optional. if is None, try to use data.vars['elev_angle'].
    return (p, t)
    """
    if type(data) is LidarDataset:
        height = data['distance'] * np.sin(np.deg2rad(elev_angle))
    else:
        height = data * np.sin(np.deg2rad(elev_angle))
    p = np.interp(height, prof.height, prof.pressure)
    t = np.interp(height, prof.height, prof.temperature)
    return p, t

def calc_betam(p, t, l=523.0, rho_n=0.02842):
    """calculates BetaM.
    p: array of pressure
    t: array of temperature.
    l: light wavelength in nm.
    rho_n: air molecule depolarization factor.
    returns array of BetaM (km-1)
    """
    assert len(p) == len(t)
    n0 = 1.000272599 #(n0-1)*10e8=6432.8+2949810/(146-lambda^-2)+25540/(41-lambda^-2), Edlen 1953
    n0_minus_1 = (6432.8+2949810.0/(146.0-np.power(l,-2))+25540.0/(41.0-np.power(l,-2)))*1.0e-8 
    #BetaM(z)=PI^2/(N0^2*lambda^4) * (n0^2-1)^2 * (6+3*rho_n)/(6-7*rho_n) * N0 * T0/P0 * P(z)/T(z)
    #and n0^2-1 can be written into 2(n0-1)
    #where N0=2.547e25 , T0=288, P0=1013.25, rho_n=0.0284, lambda=523?
    #and PI^2/N0 * T0/P0 =1.1014e-25
    betam = 1.1014e-25 * np.power((2.0*n0_minus_1),2)/pow(l*1.0e-9,4) * (6.0+3.0*rho_n) / (6.0-7.0*rho_n) * p / t * 1000.0
    return betam

_real_dir = os.path.dirname(__file__)

prof_midlatitude_summer = AtmosProfile(os.path.join(_real_dir, 'data', 'midlatitude_summer.profile'))
prof_midlatitude_winter = AtmosProfile(os.path.join(_real_dir, 'data', 'midlatitude_winter.profile'))
prof_subarctic_summer = AtmosProfile(os.path.join(_real_dir, 'data', 'subarctic_summer.profile'))
prof_subarctic_winter = AtmosProfile(os.path.join(_real_dir, 'data', 'subarctic_winter.profile'))
prof_tropical = AtmosProfile(os.path.join(_real_dir, 'data', 'tropical.profile'))
prof_us1976 = AtmosProfile(os.path.join(_real_dir, 'data', 'us1976.profile'))

if __name__ == '__main__':
    pass