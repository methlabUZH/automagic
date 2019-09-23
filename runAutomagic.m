%% start Automagic

mainGuiFile = 'mainGUI.m';

addAutomagicPaths();
[hFig] = loadingScreen();
run(mainGuiFile);
close(hFig)