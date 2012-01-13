cimport utils
cimport numpy as np
import numpy as np

cdef Particle this_particle

cdef int update_particle_data(int id) except -1:
    utils.realloc_intlist(&(this_particle.bl), 0)
    if get_particle_data(id, &this_particle):
        raise Exception("Error updating particle data")
    else: 
        return 0

def setType (_id, _type):
    cdef int id = _id
    cdef int type = _type
    if set_particle_type(id, type):
        raise Exception("set particle position first")
    else:
        return 0

def getType (_id):
    cdef int id = _id
    update_particle_data(id)
    return this_particle.p.type 

def setPos (_id, _pos):
    cdef int id = _id
    cdef double mypos[3]
    for i in range(3):
        mypos[i]=_pos[i]
    if place_particle(id, mypos):
        return 0
    else:
        raise AssertionError("particle could not be set")

def getPos(_id):
    cdef int id = _id
    update_particle_data(id)
    return np.array([this_particle.r.p[0], this_particle.r.p[1], this_particle.r.p[2]])

# if ELECTROSTATICS
def setCharge(_id, _q):
    cdef double q = _q
    cdef int id = _id
    if set_particle_q(id, q):
        raise Exception("set particle position first")
    else:
        return 0

def getCharge(_id):
    cdef int id = _id
    update_particle_data(id)
    return this_particle.p.q
    

def dosomething():
    print "I'm doing something"
    return 0
