# Digital Signal Processing Applications in Hearing Aids
## Elimination of the hearing aid’s transducer effectson the emitted signal
This is a 3rd year bioengineering project at Imperial College London that is researching into the pyscoacoustic affects of distortion induced by transducers. We explore how a transducer can affect the amplitude, phase, group delay and induce new frequencies into an input signal. We determine the psycoacoustical perception of these affects and quantify them using novel Acoustic Quality Metrics. Finaly, we aim to remove all the affects of a transducer by creating an inverse filter.

# Goals
General:
- [x] Matlab guide converted to Matlab App designer
- [x] Psycoacoustical testing of inverse filter

Inverse filter using:
- [x] Warped Finite Impulse response
- [x] Warped Infinite Impulse response
- [ ] Finite Impulse response
- [ ] Infinite Impulse response

Acoustic quality metric measuring:
- [x] Amplitude
- [ ] Amplitude in high frequency ranges
- [x] Group Delay
- [ ] Harmonic Distortion
- [ ] Interharmonic Distortion
- [ ] Phase Distortion

# Files in repository are grouped as follows:
## General:
- rgeobark.m
  - Converts a signal's phase to the default bark scale
- rgeobarkranged.m
  - Converts a signal's phase to the bark scale with specific range
- rlogbark.m
  - Converts a signal's magnitude to the default bark scale
- rlogbarkranged.m
  - Converts a signal's magnitude to the bark scale with specific range

## Inverse Filter:
- alpaToSigma.m
  - Calculates sigma value for inverse filter transfer function
- barkwarp.m
- bose_qc20_ir.mat
- boseironly.m
- if_demo.m
- **inverseFilter.m**
- warpedFIR.m
  - Transfer function for warped finite impulse response.
- warpedIIR.m
  - Transfer function for warped infinte impulse response.
- warpImpulseResponse.m
  
## Harmonic Distortion:
- AutoPeak.m
  - Calculates peak values of first three harmonics
- HarmonicFilt.m
  - Sections harmonics from a signal to be displayed
- **Harmonics.m**
  - Main function that plots graph of each harmonic and plots total harmonic distortion.
- MidFinder.m
  - Finds the midpoints between harmonics.
- PeakRemover.m
  - Remove harmonics from a signal.
- calculateTHD.m
  - Function that calcuates the total harmonic distortion of an input signal.
- removeNoise.m
  - Function that remove background noise present in the signal.

## Group Delay:
- **GDAQM.m**
  - Function that determines a score for the group delay distortion of a signal. 
- Blauert.mat
  - Audability threshold for group delay calculation.

## Amplitude Distortion:
- **AmpAQM.m**
  - Function that determines a score for the amplitude distortion of a signal.
- toleranceTube.mat
  - Limits for tolerance tube used in AmpAQM.m

---

# The Team
## Supervisors:
- [Dr Guy-Bart Stan](https://www.imperial.ac.uk/people/g.stan "Imperial College Profile")
- [Mr Christophe Hermans](https://www.resolution-acoustics.be/our-team/christophe-hermans/ "Resolution Acoustics Profile")

## Group Members:
- [Megan Allerton](https://www.linkedin.com/in/meganallerton/ "Linkedin Profile")
- [Krithika Balaji](https://www.linkedin.com/in/krithika-balaji-13961716b/ "Linkedin Profile")
- [Hongzhang (Tommy) Chen](https://www.linkedin.com/in/hongzhang-tommy-chen-066baa184/ "Linkedin Profile")
- [Marcella Iswanto](https://www.linkedin.com/in/marcella-alessandra-iswanto-carrasquero-a756b5151/ "Linkedin Profile")
- [Shivali Jain](https://www.linkedin.com/in/shivalijain-/ "Linkedin Profile")
- [Gabrielle Johnston](https://www.linkedin.com/in/gabrielle-johnston-827861155/ "Linkedin Profile")
- [Alexander McKinnon](https://www.linkedin.com/in/alex-mckinnon-1aa261198/ "Linkedin Profile")
