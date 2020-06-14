# BrownianMotion
This MATLAB code is used to run the brownian motion analysis for Teaching Lab 5/6 Active Brownian Motion experiment.
Use it as a basis for your analysis, change or take parts as needed.

## Dependencies
The analysis depends on two additional software packages:
- A modified version of [MSDAnalyzer](https://github.com/nivieru/msdanalyzer). [Original documentation and tutorial](https://tinevez.github.io/msdanalyzer/).
- [Tracker](http://site.physics.georgetown.edu/matlab/code.html). [Original documentation and tutorial](http://site.physics.georgetown.edu/matlab/index.html).

## Quick usage:
1. Download this code and the dependencies.
2. The main script is called runAnalysis.
Before running it, set the parameters trackingDir and msdDir to the path of the above mentioned dependencies, and set videoDirOrFilename to point to the location of your video file.
The script will run the particle tracking code, and analyze the resulting tracks with the MSD analyzer software.
3. Optimize script parameters, than run with `interactive = false`.

## Script parameters:
- `trackingDir` - path to the tracking code.
- `msdDir` - path to the MSDAnalyzer code.
- `videoDirOrFilename` - path to the video file or its containing directory.
- `interactive` - If true run in iteractive mode. In interactive mode the run will pause after applying bandpass to the first frame and display the original and bandpassed frames side by side.
Inspect the frames to optimize the parameters of the bandpass, find size of beads and intensity values of beads and background to decide on parameters for the peak detection and centroid detection. Additionally, `cntrd` will run in interactive mode, which displays the located particles and the region it uses for subpixel detection.
After optimizing and verifying the tracking parameters, change this to false in order to run with no interruptions.
- `timestampFlag` - If true time-stamp the output directories, avoids rewriting over previous runs.
- `trackingParameters` - structure containing various parameters used in the particle tracking. These depend on the imaging coditions - the objective used, the camera and illumination settings and so on. Read the documentation online and in the code to understand each parameter and test the output of each stage in the analysis to find the best parameters.
- `clip_factor` - region of MSD data to fit to calculate diffusion coefficient and alpha parameter.

## Main Functions:
- `runAnalysis` - Main script
- `[tracksForMsdanalyzer, framerate] = tracksFromMovie(videoDirOrFilename, trackingParameters, interactive)`
Runs the particle tracking code on the video.
Reads the video file frame by frame, applies bandpass filter to each frame, finds positions of beads to subpixel accuracy, and than composes tracks out of the pixel positions using the `track` function.
- `[ff,analysisDir] = newAnalysis(videoDirOrFilename, timestampFlag)`
Create a new analysis directory in the video directory. If `timestamp` is false, this directory could exist from a previous run and it's contect could be overwriteen by subsequent `save` commands.
Returns the function handle `ff` which can adds the full path to a filename, to be used when saving or loading, and `analysisDir`, the path to the analysis directory.
- `[ff, varargout] = loadAnalysis(analysisFolder, varargin)`
Loads selected files from analysis folder. Use ff to save or load from analysis folder.
- `[ff, ma, results] = runMSDAnalysis(analysisDir, clip_factor, forceNewAnalysis )`
Runs MSD analysis on the tracks saved to the analysis dir, or if an MSDAnalysis object is already saved to folder, load it and only do plots and fits.
clip_factr determines the region of Mean MSD used for fits.
forceNewAnalysis avoids loading of existing analysis, reruns analysis instead.
