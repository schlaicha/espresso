import ctypes
import sys
sys.setdlopenflags((sys.getdlopenflags() | ctypes.RTLD_GLOBAL ))

import espresso as es
import numpy

es._espressoHandle.Tcl_Eval("thermostat langevin 1. 1.")

# Test particle properties interface using TCL for comparison
print "Testing particle properties..."
VarId=0;

varname="pos";
es.particle_properties.setPos(0,numpy.random.random(3))
tcl_val = es._espressoHandle.Tcl_Eval("part " + str(0) + " print " + varname).split()
py_val = es.particle_properties.getPos(0)
for i in range(3):
    if ( ( numpy.fabs(float(tcl_val[i])) - numpy.fabs(py_val[i]) ) > 1e-10 ):
        raise ValueError(varname + " FAILED\n" + "Tcl".ljust(10) + str(tcl_val) + "\n" +  "python".ljust(10) + str(py_val) + "\n");
print (str(VarId)+" "+varname).ljust(20), "OK";
VarId=VarId+1;

varname="type";
es.particle_properties.setType(0,numpy.random.randint(1))
py_val = es.particle_properties.getType(0)
tcl_val = int(es._espressoHandle.Tcl_Eval("part " + str(0) + " print " + varname))
if py_val != tcl_val:
    raise ValueError(varname + " FAILED\n" + "Tcl".ljust(10) + str(tcl_val) + "\n" +  "python".ljust(10) + str(py_val) + "\n");
print (str(VarId)+" "+varname).ljust(20), "OK";
VarId=VarId+1;

try:
    varname="q"
    es.particle_properties.setCharge(0, numpy.random.random(1))
    py_val = es.particle_properties.getCharge(0)
    tcl_val = es._espressoHandle.Tcl_Eval("part " + str(0) + " print " + str(varname))
    if ( ( numpy.fabs(float(tcl_val)) - numpy.fabs(py_val) ) > 1e-10 ):
        raise ValueError(varname + " FAILED\n" + "Tcl".ljust(10) + str(tcl_val) + "\n" +  "python".ljust(10) + str(py_val) + "\n");
    print (str(VarId)+" "+varname).ljust(20), "OK";
except ValueError as detail:
    print detail
except Exception as detail:
    print (str(VarId)+" "+varname).ljust(20), "not tested as", detail;
VarId=VarId+1;

try:
    varname="mass"
    es.particle_properties.setMass(0, numpy.random.random(1))
    py_val = es.particle_properties.getMass(0)
    tcl_val = es._espressoHandle.Tcl_Eval("part " + str(0) + " print " + str(varname))
    if ( ( numpy.fabs(float(tcl_val)) - numpy.fabs(py_val) ) > 1e-10 ):
        raise ValueError(varname + " FAILED\n" + "Tcl".ljust(10) + str(tcl_val) + "\n" +  "python".ljust(10) + str(py_val) + "\n");
    print (str(VarId)+" "+varname).ljust(20), "OK";
except ValueError as detail:
    print detail
except Exception as detail:
    print (str(VarId)+" "+varname).ljust(20), "not tested as", detail;
VarId=VarId+1;
