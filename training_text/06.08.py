import sys

from pyrosetta import * 
init()
pose = pose_from_pdb("inputs/1jhl.clean.pdb")
testPose = Pose()
testPose.assign(pose)
print(testPose)

from pyrosetta.rosetta.protocols.relax import FastRelax

relax = FastRelax()
scorefxn = get_fa_scorefxn()
relax.set_scorefxn(scorefxn)
relax = rosetta.protocols.relax.FastRelax()
relax.constrain_relax_to_start_coords(True)
print(relax)

from pyrosetta.rosetta.core.pack.task import *
from pyrosetta.rosetta.protocols import *
from pyrosetta.rosetta.core.select import *

def pack(pose, posi, amino, scorefxn):

    # Select Mutate Position
    mut_posi = pyrosetta.rosetta.core.select.residue_selector.ResidueIndexSelector()
    mut_posi.set_index(posi)
    #print(pyrosetta.rosetta.core.select.get_residues_from_subset(mut_posi.apply(pose)))

    # Select Neighbor Position
    nbr_selector = pyrosetta.rosetta.core.select.residue_selector.NeighborhoodResidueSelector()
    nbr_selector.set_focus_selector(mut_posi)
    nbr_selector.set_include_focus_in_subset(True)
    #print(pyrosetta.rosetta.core.select.get_residues_from_subset(nbr_selector.apply(pose)))

    # Select No Design Area
    not_design = pyrosetta.rosetta.core.select.residue_selector.NotResidueSelector(mut_posi)
    #print(pyrosetta.rosetta.core.select.get_residues_from_subset(not_design.apply(pose)))

    # The task factory accepts all the task operations
    tf = pyrosetta.rosetta.core.pack.task.TaskFactory()

    # These are pretty standard
    tf.push_back(pyrosetta.rosetta.core.pack.task.operation.InitializeFromCommandline())
    tf.push_back(pyrosetta.rosetta.core.pack.task.operation.IncludeCurrent())
    tf.push_back(pyrosetta.rosetta.core.pack.task.operation.NoRepackDisulfides())

    # Disable Packing
    prevent_repacking_rlt = pyrosetta.rosetta.core.pack.task.operation.PreventRepackingRLT()
    prevent_subset_repacking = pyrosetta.rosetta.core.pack.task.operation.OperateOnResidueSubset(prevent_repacking_rlt, nbr_selector, True )
    tf.push_back(prevent_subset_repacking)

    # Disable design
    tf.push_back(pyrosetta.rosetta.core.pack.task.operation.OperateOnResidueSubset(
        pyrosetta.rosetta.core.pack.task.operation.RestrictToRepackingRLT(),not_design))

    # Enable design
    aa_to_design = pyrosetta.rosetta.core.pack.task.operation.RestrictAbsentCanonicalAASRLT()
    aa_to_design.aas_to_keep(amino)
    tf.push_back(pyrosetta.rosetta.core.pack.task.operation.OperateOnResidueSubset(aa_to_design, mut_posi))
    
    # Create Packer
    packer = pyrosetta.rosetta.protocols.minimization_packing.PackRotamersMover()
    packer.task_factory(tf)

    #Perform The Move
    if not os.getenv("DEBUG"):
      packer.apply(pose)

#Load the previously-relaxed pose.
relaxPose = pose_from_pdb("inputs/test.relax.pdb")

#Clone it
original = relaxPose.clone()
scorefxn = get_score_function()
print("\nOld Energy:", scorefxn(original),"\n")
pack(relaxPose, 130, 'A', scorefxn)
print("\nNew Energy:", scorefxn(relaxPose),"\n")

#Set relaxPose back to original
relaxPose = original.clone()

from pyrosetta.rosetta.protocols import *

def unbind(pose, partners):
    STEP_SIZE = 100
    JUMP = 2
    docking.setup_foldtree(pose, partners, Vector1([-1,-1,-1]))
    trans_mover = rigid.RigidBodyTransMover(pose,JUMP)
    trans_mover.step_size(STEP_SIZE)
    trans_mover.apply(pose)


##Reset the original pose
relaxPose = original.clone()

scorefxn = get_score_function()
bound_score = scorefxn(relaxPose)
print("\nBound State Score",bound_score,"\n")
unbind(relaxPose, "HL_A")
unbound_score = scorefxn(relaxPose)

print("\nUnbound State Score", unbound_score,"\n")
print('dG', bound_score - unbound_score, 'Rosetta Energy Units (REU)')

def wildtype(aatype = 'AA.aa_gly'):
    AA = ['G','A','L','M','F','W','K','Q','E','S','P'
            ,'V','I','C','Y','H','R','N','D','T']

    AA_3 = ['AA.aa_gly','AA.aa_ala','AA.aa_leu','AA.aa_met','AA.aa_phe','AA.aa_trp'
            ,'AA.aa_lys','AA.aa_gln','AA.aa_glu', 'AA.aa_ser','AA.aa_pro','AA.aa_val'
            ,'AA.aa_ile','AA.aa_cys','AA.aa_tyr','AA.aa_his','AA.aa_arg','AA.aa_asn'
            ,'AA.aa_asp','AA.aa_thr']

    for i in range(0, len(AA_3)):
        if(aatype == AA_3[i]):
            return AA[i]

print(wildtype(str(relaxPose.aa(130))))

def mutate(pose, posi, amino, partners):
    #main function for mutation
    CSV_PREFIX = 'notec'
    PDB_PREFIX = 'notep'

    #Initiate test pose
    testPose = Pose()
    testPose.assign(pose)

    #Initiate energy function
    scorefxn = get_fa_scorefxn()
    unbind(testPose, partners)
    native_ub = scorefxn(testPose)
    testPose.assign(pose)
    
    #Variables initiation
    content = ''
    name = CSV_PREFIX + str(posi)+str(amino) + '.csv'
    pdbname = PDB_PREFIX + str(posi)+str(amino) + '.pdb'
    wt = wildtype(str(pose.aa(posi)))

    pack(testPose, posi, amino, scorefxn)
    testPose.dump_pdb(pdbname)
    bound = scorefxn(testPose)
    unbind(testPose, partners)
    unbound = scorefxn(testPose)
    binding = unbound - bound
    testPose.assign(pose)

    if (wt == amino):
        wt_energy = binding
    else:
        pack(testPose, posi, wt, scorefxn)
        wtbound = scorefxn(testPose)
        unbind(testPose, partners)
        wtunbound = scorefxn(testPose)
        wt_energy = wtunbound - wtbound
        testPose.assign(pose)

    content=(content+str(pose.pdb_info().pose2pdb(posi))+','+str(amino)+','
              +str(native_ub)+','+str(bound)+','+str(unbound)+','+str(binding)+','
              +str(wt_energy)+','+str(wt)+','+str(binding/wt_energy)+'\n')

    f = open(name,'w+')
    f.write(content)
    f.close()

mutate(relaxPose, 130, 'A', 'HL_A')

#NOTE - This takes a very long time!!  
# You may skip this block to continue the tutorial with pre-configured outputs.
if not os.getenv("DEBUG"):
  for i in [92,85,68,53,5,45,44,42,32,31,22,108,100]:
    print("\nMutating Position: ",str(i),"\n")
    for j in ['G','A','L','M','F','W','K','Q','E','S','P','V','I','C','Y','H','R','N','D','T']:
      mutate(relaxPose, i, j, 'HL_A')
