# Digital Signal Processing Applications in Hearing Aids
## Elimination of the hearing aid’s transducer effectson the emitted signal
This is a 3rd year bioengineering project at Imperial College London that is researching into the psychoacoustic effects of distortion induced by transducers. We explore how a transducer can affect the amplitude, phase, group delay and induce new frequencies into an input signal. We determine the psychoacoustic perception of these effects and quantify them using novel Acoustic Quality Metrics. Finaly, we aim to remove all the effects of a transducer by creating an inverse filter.

# Goals
General:
- [x] Matlab guide converted to Matlab App designer
- [x] Psychoacoustical testing of inverse filter

Inverse filter using:
- [x] Warped FIR filtering
- [x] Warped IIR filtering
- [ ] FIR filtering
- [ ] IIR filtering

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
  - This will be phased out and completely replaced with rgeobarkranged in future code
- rgeobarkranged.m
  - Converts a signal's phase to the bark scale with specific range
- rlogbark.m
  - Converts a signal's magnitude to the default bark scale
  - This will be phased out and completely replaced with rlogbarkranged in future code
- rlogbarkranged.m
  - Converts a signal's magnitude to the bark scale with specific range

## Inverse Filter:
- alpaToSigma.m
  - Calculates sigma value for inverse filter warped IIR transfer function
- barkwarp.m
  - Calculates lambda value based on sampling frequency
- bose_qc20_ir.mat
  - Impulse response of the Bose QC20 headphones
- boseironly.m
  - Creates warped FIR and warped IIR inverse filters for the Bose QC20 headphones impulse response
- if_demo.m
  - Code for testing and demonstrating different inverse filters and functions
- inverseFilter.m
  - Function for finding minimum phase and all-pass inverse filter components in the frequency domain
- warpedFIR.m
  - Applies a warped FIR filter
- warpedIIR.m
  - Applies a warped IIR filter
- warpImpulseResponse.m
  - Warps the impulse response so that warped FIR or warped IIR filter coefficients can be found
  
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
