from espresso cimport *

## Here most of the particle properties shall be accesible
## in a procedural way

cimport numpy as np
from utils cimport *

cdef extern from "../src/particle_data.h":
    ctypedef struct ParticleProperties:
        int type
        # if ELECTROSTATICS
        double q
    ctypedef struct ParticlePosition:
        double p[3]
    ctypedef struct Particle:
        ParticlePosition r
        ParticleProperties p
        IntList bl

    int get_particle_data(int part, Particle *data)

    int set_particle_type(int part, int type)
    int set_particle_q(int part, double q)
    int place_particle(int part, double p[3])


