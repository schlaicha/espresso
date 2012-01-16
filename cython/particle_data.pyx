cimport numpy as np
import numpy as np
cimport utils

include "myconfig.pxi"

cdef class ParticleHandle:
    def __cinit__(self, _id):
#        utils.init_intlist(self.particleData.el)
        utils.init_intlist(&(self.particleData.bl))
        self.id=_id

    cdef int update_particle_data(self) except -1:
#        utils.realloc_intlist(self.particleData.el, 0)
#        utils.realloc_intlist(&(self.particleData.bl), 0)
      
        if get_particle_data(self.id, &self.particleData):
            raise Exception("Error updating particle data")
        else: 
            return 0

    property pos:
        def __set__(self, _pos):
            cdef double mypos[3]
            for i in range(3):
                mypos[i]=_pos[i]
            place_particle(self.id, mypos)
        def __get__(self):
            self.update_particle_data()
            return np.array([self.particleData.r.p[0],\
                    self.particleData.r.p[1], self.particleData.r.p[2]])
 
    property type:
        def __set__(self, _type):
            cdef int type = _type
            if set_particle_type(self.id, type):
                raise Exception("set particle position first")
        def __get__(self):
            self.update_particle_data()
            return self.particleData.p.type

    IF ELECTROSTATICS == 1:
        property q:
            def __set__(self, _q):
                cdef double q = _q
                if set_particle_q(self.id, q):
                    raise Exception("set particle position first")
            def __get__(self):
                self.update_particle_data()
                return self.particleData.p.q

    IF MASS == 1:
        property mass:
            def __set__(self, _mass):
                cdef double mass = _mass
                if set_particle_mass(self.id, mass):
                    raise Exception("set particle position first")
            def __get__(self):
                self.update_particle_data()
                return self.particleData.p.mass



cdef class particleList:
  def __getitem__(self, key):
    return ParticleHandle(key)
