from espresso cimport *

## Here we create something to handle particles

cimport numpy as np
from utils cimport *

include "myconfig.pxi"

cdef extern from "../src/particle_data.h":
#  ctypedef struct IntList:
#    pass
    ctypedef struct ParticleProperties:
        int type
        #IF ELECTROSTATICS == 1:
        double q
        #IF MASS == 1:
        double mass
    ctypedef struct ParticlePosition:
        double p[3]
    ctypedef struct ParticleLocal:
       pass
    ctypedef struct ParticleMomentum:
        pass
    ctypedef struct ParticleForce:
        pass
    IF LB == 1:
        ctypedef struct ParticleLatticeCoupling:
            pass
    ctypedef struct Particle:
        ParticleProperties p
        ParticlePosition r
        ParticleMomentum m
        ParticleForce f
        ParticleLocal l
        IntList bl
    IF LB == 1:
        ParticleLatticeCoupling lc
    IF EXCLUSIONS == 1:
        IntList el
  
    int get_particle_data(int part, Particle *data)
    int place_particle(int part, double p[3])

    int set_particle_type(int part, int type)

    IF ELECTROSTATICS == 1:
        int set_particle_q(int part, double q)
    IF MASS == 1:
        int set_particle_mass(int part, double mass)

cdef class ParticleHandle:
    cdef public int id
    cdef bint valid
    cdef Particle particleData
    cdef int update_particle_data(self)
