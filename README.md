# MRFresidualSigsCorticalChar
The step-by-step image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals" are provided here. <br/>
FSL 5.0.10 should be installed on your path. <br/>
<ul>
  <li>Step000: converts 1000 DICOM MRF images of each slice to NIFTI.  </li>
  <li>Step 1: brain tissue extraction of all images, using FSL BET </li>  
  <li>Step 2: linearly co-registered (using 2D FSL FLIRT with 6 DOF) and then averaged 2D MRF images of the three repetitions for each slice. </li> 
  <li>Step 3-5: the brain-extracted MP2RAGE images were co-registered with the averaged 2D MRF images, using FSL FLIRT with 6 DOF.  </li>
  <li>Step 6: co-registers the SA2RAGE images with the averaged 2D MRF images through a two-level linear registration (using FSL FLIRT with 6 DOF).</li>
</ul>

