[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 120
  ny = 120
  nz = 0
  xmin = 0
  xmax = 40
  ymin = 0
  ymax = 40
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  # concentration Sn
  # chemical potential
  # phase concentration  Sn in Cu
  # phase concentration  Sn in Cu6Sn5
  # phase concentration  Sn in Sn
  # order parameter Cu
  # order parameter Cu6Sn5
  # order parameter Sn
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
  [./c_cu]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.15
  [../]
  [./c_imc]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.45
  [../]
  [./c_sn]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.9
  [../]
  [./eta_cu]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta_imc]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta_sn]
    # initial_condition = 0.0
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  # Kernels for split Cahn-Hilliard equation without composition gradent term(?)
  # Cahn-Hilliard Equation
  # 
  # KKS conditions
  # enforce pointwise equality of chemical potentials, n-1 kernels needed (mu_1=mu_2, mu_2=mu_3, ..., mu_n-1=mu_n
  # Kernels for Allen-Cahn equation for Cu
  # Kernels for Allen-Cahn equation for Cu6Sn5
  # Kernels for Allen-Cahn equation for Sn
  [./CHBulk]
    # Gives the residual for the concentration, dF/dc-mu
    # args_a = 'c_cu'
    type = KKSSplitCHCRes
    variable = c
    ca = c_imc
    cb = c_sn
    fa_name = fch_imc # only fa is used
    fb_name = fch_sn
    w = w
    h_name = h_imc
  [../]
  [./dcdt]
    # Gives dc/dt
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./ckernel]
    # Gives residual for chemical potential dc/dt+M\grad(mu)
    type = SplitCHWRes
    mob_name = M
    variable = w
  [../]
  [./chempot_cu_imc]
    type = KKSPhaseChemicalPotential
    variable = c_cu
    cb = c_imc
    fa_name = fch_cu
    fb_name = fch_imc
  [../]
  [./chempot_sn_cu]
    type = KKSPhaseChemicalPotential
    variable = c_imc
    cb = c_sn
    fa_name = fch_imc
    fb_name = fch_sn
  [../]
  [./phaseconcentration]
    # enforce c = sum h_i*c_i
    type = KKSMultiPhaseConcentration
    variable = c_sn
    cj = 'c_cu c_imc c_sn'
    hj_names = 'h_cu h_imc h_sn'
    etas = 'eta_cu eta_imc eta_sn'
    c = c
  [../]
  [./detadt_cu]
    type = TimeDerivative
    variable = eta_cu
  [../]
  [./ACBulkF_cu]
    # sum_j dh_j/deta_i*F_j+w*dg/deta_i, last term is not used
    type = KKSMultiACBulkF
    variable = eta_cu
    Fj_names = 'fch_cu fch_imc fch_sn'
    hj_names = 'h_cu h_imc h_sn'
    gi_name = g_cu
    eta_i = eta_cu
    wi = 0
    mob_name = L
    args = 'c_cu c_imc c_sn eta_imc eta_sn'
  [../]
  [./ACBulkC_cu]
    # -L\sum_j dh_j/deta_i*mu_jc_j
    type = KKSMultiACBulkC
    variable = eta_cu
    Fj_names = 'fch_cu fch_imc fch_sn'
    hj_names = 'h_cu h_imc h_sn'
    cj_names = 'c_cu c_imc c_sn'
    eta_i = eta_cu
    mob_name = L
    args = 'eta_imc eta_sn'
  [../]
  [./ACInterface_cu]
    # L*kappa*grad\eta_i
    type = ACInterface
    variable = eta_cu
    kappa_name = kappa
    mob_name = L
  [../]
  [./ACdfintdeta_cu]
    type = ACGrGrMulti
    variable = eta_cu
    v = 'eta_imc eta_sn'
    gamma_names = 'gamma gamma'
  [../]
  [./detadt_imc]
    type = TimeDerivative
    variable = eta_imc
  [../]
  [./ACBulkF_imc]
    # sum_j dh_j/deta_i*F_j+w*dg/deta_i, last term is not used
    type = KKSMultiACBulkF
    variable = eta_imc
    Fj_names = 'fch_cu fch_imc fch_sn'
    hj_names = 'h_cu h_imc h_sn'
    gi_name = g_imc
    eta_i = eta_imc
    wi = 0
    mob_name = L
    args = 'c_cu c_imc c_sn eta_cu eta_sn'
  [../]
  [./ACBulkC_imc]
    # -L\sum_j dh_j/deta_i*mu_jc_j
    type = KKSMultiACBulkC
    variable = eta_imc
    Fj_names = 'fch_cu fch_imc fch_sn'
    hj_names = 'h_cu h_imc h_sn'
    cj_names = 'c_cu c_imc c_sn'
    eta_i = eta_imc
    mob_name = L
    args = 'eta_cu eta_sn'
  [../]
  [./ACInterface_imc]
    # L*kappa*grad\eta_i
    type = ACInterface
    variable = eta_imc
    kappa_name = kappa
    mob_name = L
  [../]
  [./ACdfintdeta_imc]
    type = ACGrGrMulti
    variable = eta_imc
    v = 'eta_cu eta_sn'
    gamma_names = 'gamma gamma'
  [../]
  [./detadt_sn]
    type = TimeDerivative
    variable = eta_sn
  [../]
  [./ACBulkF_sn]
    # sum_j dh_j/deta_i*F_j+w*dg/deta_i, last term is not used
    type = KKSMultiACBulkF
    variable = eta_sn
    Fj_names = 'fch_cu fch_imc fch_sn'
    hj_names = 'h_cu h_imc h_sn'
    gi_name = g_sn
    eta_i = eta_sn
    wi = 0
    mob_name = L
    args = 'c_cu c_imc c_sn eta_imc eta_cu'
  [../]
  [./ACBulkC_sn]
    # -L\sum_j dh_j/deta_i*mu_jc_j
    type = KKSMultiACBulkC
    variable = eta_sn
    Fj_names = 'fch_cu fch_imc fch_sn'
    hj_names = 'h_cu h_imc h_sn'
    cj_names = 'c_cu c_imc c_sn'
    eta_i = eta_sn
    mob_name = L
    args = 'eta_cu eta_imc'
  [../]
  [./ACInterface_sn]
    # L*kappa*grad\eta_i
    type = ACInterface
    variable = eta_sn
    kappa_name = kappa
    mob_name = L
  [../]
  [./ACdfintdeta_sn]
    type = ACGrGrMulti
    variable = eta_sn
    v = 'eta_cu eta_imc'
    gamma_names = 'gamma gamma'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -sub_pc_type   -sub_pc_factor_shift_type'
  petsc_options_value = 'asm       ilu            nonzero'
  l_max_its = 30
  nl_max_its = 10
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-10
  nl_abs_tol = 1.0e-11
  num_steps = 100
  dt = 0.5
[]

[Outputs]
  exodus = true
[]

