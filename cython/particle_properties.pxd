from espresso cimport *

## Here most of the particle properties shall be accesible
## in a procedural way

cimport numpy as np
from utils cimport *

include "myconfig.pxi"

cdef extern from "../src/particle_data.h":
    ctypedef struct ParticleProperties:
        int type
        #IF ELECTROSTATICS == 1:
        double q
        #IF MASS == 1:
        double mass
    ctypedef struct ParticlePosition:
        double p[3]
    ctypedef struct Particle:
        ParticlePosition r
        ParticleProperties p
        IntList bl

    int get_particle_data(int part, Particle *data)

    int set_particle_type(int part, int type)
    int place_particle(int part, double p[3])

    IF ELECTROSTATICS == 1:
        int set_particle_q(int part, double q)
    IF MASS == 1:
        int set_particle_mass(int part, double mass)
