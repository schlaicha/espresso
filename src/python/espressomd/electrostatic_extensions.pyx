#
# Copyright (C) 2013-2019 The ESPResSo project
#
# This file is part of ESPResSo.
#
# ESPResSo is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ESPResSo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

from . cimport utils
include "myconfig.pxi"
from . cimport actors
from . import actors
import numpy as np
from .utils import handle_errors
from .utils cimport check_type_or_throw_except, check_range_or_except

IF ELECTROSTATICS and P3M:
    from espressomd.electrostatics import check_neutrality

    cdef class ElectrostaticExtensions(actors.Actor):
        pass

    cdef class ICC(ElectrostaticExtensions):
        """
        Interface to the induced charge calculation scheme for dielectric
        interfaces. See :ref:`Dielectric interfaces with the ICC algorithm`
        for more details.

        Parameters
        ----------
        n_icc : :obj:`int`
            Total number of ICC Particles.
        first_id : :obj:`int`, optional
            ID of the first ICC Particle.
        convergence : :obj:`float`, optional
            Abort criteria of the iteration. It corresponds to the maximum relative
            change of any of the interface particle's charge.
        relaxation : :obj:`float`, optional
            SOR relaxation parameter.
        ext_field : :obj:`float`, optional
            Homogeneous electric field added to the calculation of dielectric boundary forces.
        max_iterations : :obj:`int`, optional
            Maximal number of iterations.
        eps_out : :obj:`float`, optional
            Relative permittivity of the outer region (where the particles are).
        normals : (``n_icc``, 3) array_like :obj:`float`
            Normal vectors pointing into the outer region.
        areas : (``n_icc``, ) array_like :obj:`float`
            Areas of the discretized surface.
        sigmas : (``n_icc``, ) array_like :obj:`float`, optional
            Additional surface charge density in the absence of any charge
            induction.
        epsilons : (``n_icc``, ) array_like :obj:`float`, optional
            Dielectric constant associated to the areas.

        """

        def validate_params(self):
            default_params = self.default_params()

            check_type_or_throw_except(self._params["n_icc"], 1, int, "")
            check_range_or_except(
                self._params, "n_icc", 1, True, "inf", True)

            check_type_or_throw_except(
                self._params["convergence"], 1, float, "")
            check_range_or_except(
                self._params, "convergence", 0, False, "inf", True)

            check_type_or_throw_except(
                self._params["relaxation"], 1, float, "")
            check_range_or_except(
                self._params, "relaxation", 0, False, "inf", True)

            check_type_or_throw_except(
                self._params["ext_field"], 3, float, "")

            check_type_or_throw_except(
                self._params["max_iterations"], 1, int, "")
            check_range_or_except(
                self._params, "max_iterations", 0, False, "inf", True)

            check_type_or_throw_except(
                self._params["first_id"], 1, int, "")
            check_range_or_except(
                self._params, "first_id", 0, True, "inf", True)

            check_type_or_throw_except(
                self._params["eps_out"], 1, float, "")

            n_icc = self._params["n_icc"]

            # Required list input
            self._params["normals"] = np.array(self._params["normals"])
            if self._params["normals"].size != n_icc * 3:
                raise ValueError(
                    "Expecting normal list with " + str(n_icc * 3) + " entries.")
            check_type_or_throw_except(self._params["normals"], n_icc,
                                       np.ndarray, "Error in normal list.")

            check_type_or_throw_except(
                self._params["areas"], n_icc, float, "Error in area list.")

            # Not Required
            if "sigmas" in self._params.keys():
                check_type_or_throw_except(
                    self._params["sigmas"], n_icc, float, "Error in sigma list.")
            else:
                self._params["sigmas"] = np.zeros(n_icc)

            if "epsilons" in self._params.keys():
                check_type_or_throw_except(
                    self._params["epsilons"], n_icc, float, "Error in epsilon list.")
            else:
                self._params["epsilons"] = np.zeros(n_icc)

        def valid_keys(self):
            return ["n_icc", "convergence", "relaxation", "ext_field",
                    "max_iterations", "first_id", "eps_out", "normals",
                    "areas", "sigmas", "epsilons", "check_neutrality"]

        def required_keys(self):
            return ["n_icc", "normals", "areas"]

        def default_params(self):
            return {"n_icc": 0,
                    "convergence": 1e-3,
                    "relaxation": 0.7,
                    "ext_field": [0, 0, 0],
                    "max_iterations": 100,
                    "first_id": 0,
                    "esp_out": 1,
                    "normals": [],
                    "areas": [],
                    "sigmas": [],
                    "epsilons": [],
                    "check_neutrality": True}

        def _get_params_from_es_core(self):
            params = {}
            params["n_icc"] = icc_cfg.n_ic

            # Fill Lists
            normals = []
            areas = []
            sigmas = []
            epsilons = []
            for i in range(icc_cfg.n_ic):
                normals.append([icc_cfg.normals[i][0], icc_cfg.normals[
                               i][1], icc_cfg.normals[i][2]])
                areas.append(icc_cfg.areas[i])
                epsilons.append(icc_cfg.ein[i])
                sigmas.append(icc_cfg.sigma[i])

            params["normals"] = normals
            params["areas"] = areas
            params["epsilons"] = epsilons
            params["sigmas"] = sigmas

            params["ext_field"] = [icc_cfg.ext_field[0],
                                   icc_cfg.ext_field[1],
                                   icc_cfg.ext_field[2]]
            params["first_id"] = icc_cfg.first_id
            params["max_iterations"] = icc_cfg.num_iteration
            params["convergence"] = icc_cfg.convergence
            params["relaxation"] = icc_cfg.relax
            params["eps_out"] = icc_cfg.eout

            return params

        def _set_params_in_es_core(self):
            # First set number of icc particles
            icc_cfg.n_ic = self._params["n_icc"]
            # Allocate ICC lists
            icc_alloc_lists()

            # Fill Lists
            for i in range(icc_cfg.n_ic):
                icc_cfg.normals[i][0] = self._params["normals"][i][0]
                icc_cfg.normals[i][1] = self._params["normals"][i][1]
                icc_cfg.normals[i][2] = self._params["normals"][i][2]

                icc_cfg.areas[i] = self._params["areas"][i]
                icc_cfg.ein[i] = self._params["epsilons"][i]
                icc_cfg.sigma[i] = self._params["sigmas"][i]

            icc_cfg.ext_field[0] = self._params["ext_field"][0]
            icc_cfg.ext_field[1] = self._params["ext_field"][1]
            icc_cfg.ext_field[2] = self._params["ext_field"][2]
            icc_cfg.first_id = self._params["first_id"]
            icc_cfg.num_iteration = self._params["max_iterations"]
            icc_cfg.convergence = self._params["convergence"]
            icc_cfg.relax = self._params["relaxation"]
            icc_cfg.eout = self._params["eps_out"]

            # Broadcasts vars
            mpi_icc_init()

        def _activate_method(self):
            check_neutrality(self._params)
            self._set_params_in_es_core()

        def _deactivate_method(self):
            icc_cfg.n_ic = 0
            # Allocate ICC lists
            icc_alloc_lists()

            # Broadcasts vars
            mpi_icc_init()

        def last_iterations(self):
            """
            Number of iterations needed in last relaxation to
            reach the convergence criterion.

            Returns
            -------
            iterations : :obj:`int`
                Number of iterations

            """
            return icc_cfg.citeration
