# Digital Signal Processing Applications in Hearing Aids
## Elimination of the hearing aid transducer's effects on the emitted signal
This is a 3rd year bioengineering project at Imperial College London that is researching into the psychoacoustic effects of distortion induced by transducers. We explore how a transducer can affect the amplitude, phase, group delay and induce new frequencies into an input signal. We determine the psychoacoustic perception of these effects and quantify them using novel Acoustic Quality Metrics. Finaly, we aim to remove all the effects of a transducer by creating an inverse filter.

# Files in repository are grouped as follows:
## General:
- rlogbarkrangedv2.m
  - Calculates the log mean at certain points given by the bark scale over a rectangular window with a frequency dependent width
  - Outputs the points and the frequency spacing of the points
  - The ouput frequency range can be optionally specified
  - *Note:* this function replaces rlogbark.m and rlogbarkranged.m. If any files exist using either of these functions please replace them with this function. 
- rgeobarkrangedv2.m
  - Calculates the geometric mean at certain points given by the bark scale over a rectangular window with a frequency dependent width
  - Outputs the points and the frequency spacing of the points
  - The ouput frequency range can be optionally specified
  - *Note:* this function replaces rgeobark.m and rgeobarkranged.m. If any files exist using either of these functions please replace them with this function. 

## Inverse Filter:
- alpaToSigma.m
  - Calculates sigma value for inverse filter warped IIR transfer function
- ampegif.m
  - Example file for finding inverse filter with all methods
  - See [https://soundwoofer.com/Library/Index](https://soundwoofer.com/Library/Index) for impulse response used (freely available). 
- ashdownif.m
  - Example file for finding inverse filter with all methods
  - See [https://soundwoofer.com/Library/Index](https://soundwoofer.com/Library/Index) for impulse response used (freely available). 
- barkwarp.m
  - Calculates lambda value based on sampling frequency
- inverseFilter.m
  - Function for finding minimum phase and all-pass inverse filter components in the frequency domain
- inverseFilterv3.m
  - *New* version of function for finding minimum phase and all-pass inverse filter components in the frequency domain
- inverseFilterTime.m 
  - Finds the inverse filter in the time domain method using the method in [http://www.aes.org/e-lib/browse.cfm?elib=12098](http://www.aes.org/e-lib/browse.cfm?elib=12098). 
 - if_test.m
  - Example file for finding inverse filter with all methods
  - Uses impulse response provided at start of project (IR19061314201696-1.wav)
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
- [Prof Guy-Bart Stan](https://www.imperial.ac.uk/people/g.stan "Imperial College Profile")
- [Mr Christophe Hermans](https://www.resolution-acoustics.be/our-team/christophe-hermans/ "Resolution Acoustics Profile")

## Group Members:
- [Megan Allerton](https://www.linkedin.com/in/meganallerton/ "Linkedin Profile")
- [Krithika Balaji](https://www.linkedin.com/in/krithika-balaji-13961716b/ "Linkedin Profile")
- [Hongzhang (Tommy) Chen](https://www.linkedin.com/in/hongzhang-tommy-chen-066baa184/ "Linkedin Profile")
- [Marcella Iswanto](https://www.linkedin.com/in/marcella-alessandra-iswanto-carrasquero-a756b5151/ "Linkedin Profile")
- [Shivali Jain](https://www.linkedin.com/in/shivalijain-/ "Linkedin Profile")
- [Gabrielle Johnston](https://www.linkedin.com/in/gabrielle-johnston-827861155/ "Linkedin Profile")
- [Alexander McKinnon](https://www.linkedin.com/in/alex-mckinnon-1aa261198/ "Linkedin Profile")
