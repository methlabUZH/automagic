function EEG = performFilter(EEG, varargin)
% performFilter  perform a high pass, low pass and notch filter.
%
%   filtered = performFilter(EEG, params)
%   where EEG is the EEGLAB data structure. filtered is the resulting
%   EEGLAB data structured after filtering. params is an optional
%   parameter which must be a structure with optional parameters
%   'notch', 'high', 'low' or 'firws', each of which a struct. 
%   An example of this parameter is given below:
%   params = struct('notch', struct('freq', 50),...
%                   'high',  struct('freq', 0.5, 'order', []),...
%                   'low',   struct('freq', 30,  'order', []))
%
%   'notch.freq' is the frequency for the notch filter where from
%   (notch_freq - 3) to (notch_freq + 3) is attenued.
%
%   'high.freq' and 'high.order' are the frequency and filtering order for
%   high pass filter respectively.
%
%   'low.freq' and 'low.order' are the frequency and filtering order for
%   low pass filter respectively.
%
%   In the case of filtering ordering, if it is left to be high.order = []
%   (or low.order = []), then the default value of pop_eegfiltnew.m is
%   used.
%
%   The above filters are performed using pop_eegfiltnew.m. However, if 
%   'firsw' is provided, then 'pop_firws' is used. In this case, high and
%   low pass filters even if given as parameters are ignored.
%   The 'firws' strcut must have a single memeber called 'firws.com' which 
%   is a string similar to the following line to be evaluated:
%
%   firws.com = 'EEG = pop_firws(EEG, 'fcutoff', [12 1], 'ftype', ...
%          'bandpass', 'wtype', 'blackman', 'forder', 2, 'minphase', 0);'
%
%   Note that this string can be obtained by calling once the 'pop_firws'
%   on an example EEG structure and filling in the input GUI.
%
%   If params is ommited default values are used. If any field of params
%   are ommited, corresponding default values are used. If
%   'params.notch = struct([])', 'params.high = struct([])' or
%   'params.low = struct([])' then notch filter, high pass filter or
%   low pass filter are not perfomed respectively.
%
%   Default values are specified in DefaultParameters.m. If they are empty
%   then defaults of inexact_alm_rpca.m are used.
%
% Copyright (C) 2017  Amirreza Bahreini, methlabuzh@gmail.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

defaults = DefaultParameters.FilterParams;
recs = RecommendedParameters.FilterParams;
if isempty(defaults)
    defaults = recs;
end

%% Parse parameters
p = inputParser;
addParameter(p,'notch', defaults.notch, @isstruct);
addParameter(p,'firws', defaults.firws, @isstruct);
addParameter(p,'high', defaults.high, @isstruct);
addParameter(p,'low', defaults.low, @isstruct);
addParameter(p,'zapline', defaults.zapline, @isstruct);
addParameter(p,'zaplineplus', defaults.zaplineplus, @isstruct);
parse(p, varargin{:});
notch = p.Results.notch;
high = p.Results.high;
low = p.Results.low;
firws = p.Results.firws;
zapline = p.Results.zapline;
zaplineplus = p.Results.zaplineplus;

if( ~isempty(high) )
    if ~isfield(high, 'freq')
        warning(['high.freq is not given but is required. Default parameters '...
            'for high pass filtering will be used'])
        high = defaults.high;
    elseif ~isfield(high, 'order')
        high.order = defaults.order;
    end
end

if( ~isempty(low) )
    if ~isfield(low, 'freq')
        warning(['low.freq is not given but is required. Default parameters '...
            'for low pass filtering will be used'])
        low = defaults.low;
    elseif ~isfield(low, 'order')
        low.order = defaults.order;
    end
end

if( ~isempty(notch) && ~isfield(notch, 'freq'))
    warning(['Input argument to notch filter is not complete. notch.freq',...
        'must be provided. The default will be used.'])
    notch = defaults.notch;
end

if( ~isempty(zapline) && ~isfield(zapline, 'freq'))
    warning(['Input argument to Zapline filter is not complete. zapline.freq',...
        'must be provided. The default will be used.'])
    zapline = defaults.zapline;
end
%% Perform filtering
EEG.automagic.filtering.performed = 'no';
if( ~isempty(high) || ~isempty(low) || ~isempty(notch) || ~isempty(zapline) || ~isempty(zaplineplus) || ~isempty(firws))
    EEG.automagic.filtering.performed = 'yes';
    
    if ~isempty(firws) && ~isempty(firws.high) 
        EEG.automagic.filtering.firws.high.performed = 'yes';

        [~, EEG, com, ~] = evalc(firws.high.com(7:end));
        args = strsplit(erase(com, ['''', ';', '(', ')']), ',');
        for i = 2:2:(length(args)-1)
            EEG.automagic.filtering.firws.high.(strtrim(erase(args{i}, "'"))) = strtrim(erase(args{i+1}, "'"));
        end
    else
        EEG.automagic.filtering.firws.high.performed = 'no';
    end

    if( ~isempty(high) && (isempty(firws) || isempty(firws.high)))
        [out, EEG, ~ , b] = evalc('pop_eegfiltnew(EEG, high.freq, 0, high.order)');
        splits = strsplit(out, '\n');
        curoff_line = strsplit(splits{4}, ' ');
        cuttoff_freq = curoff_line{end-1};
        
        EEG.automagic.filtering.highpass.performed = 'yes';
        EEG.automagic.filtering.highpass.freq = high.freq;
        EEG.automagic.filtering.highpass.order = length(b)-1;
        EEG.automagic.filtering.highpass.transitionBandWidth = 3.3 / (length(b)-1) * EEG.srate;
        EEG.automagic.filtering.highpass.cutoff_freq = str2double(cuttoff_freq);
    else
        EEG.automagic.filtering.highpass.performed = 'no';
    end
    
    
    if( ~isempty(notch) )
        [~, EEG, ~ , b] = evalc(['pop_eegfiltnew(EEG, notch.freq - 3,'...
            'notch.freq + 3, [], 1)']); % Band-stop filter
        EEG.automagic.filtering.notch.performed = 'yes';
        EEG.automagic.filtering.notch.freq = notch.freq;
        EEG.automagic.filtering.notch.order = length(b)-1;
        EEG.automagic.filtering.notch.transitionBandWidth = 3.3 / (length(b)-1) * EEG.srate;
    else
        EEG.automagic.filtering.notch.performed = 'no';
    end
    
    % ZapLine
    if( ~isempty(zapline) )
        x = EEG.data';
        fline = zapline.freq / EEG.srate; % line frequency normalised to srate
        NREMOVE=zapline.ncomps; % number of components to remove
        [~,clean,~]= evalc('nt_zapline(x, fline ,NREMOVE)');
        EEG.data = clean';
        EEG.automagic.filtering.zapline.performed = 'yes';
        EEG.automagic.filtering.zapline.freq = zapline.freq;
        if ~isfield(zapline,'finalPlot')
            disp('Generating ZapLine figure');
            fig1 = figure('visible', 'off');
            set(gcf, 'Color', [1,1,1])
            hold on
            y=clean;
            nfft = 1024;
            subplot 121
            [pxx,f]=nt_spect_plot(x/sqrt(mean(x(:).^2)),nfft,[],[],1/fline);
            divisor=sum(pxx);
            semilogy(f,abs(pxx)/divisor);
            legend('original'); legend boxoff
            set(gca,'ygrid','on','xgrid','on');
            xlabel('frequency (relative to line)');
            ylabel('relative power');
            yl1=get(gca,'ylim');
            hh=get(gca,'children');
            set(hh(1),'color','k')
            subplot 122
            [pxx,f]=nt_spect_plot(y/sqrt(mean(x(:).^2)),nfft,[],[],1/fline);
            semilogy(f,abs(pxx)/divisor);
            hold on
            [pxx,f]=nt_spect_plot((x-y)/sqrt(mean(x(:).^2)),nfft,[],[],1/fline);
            semilogy(f,abs(pxx)/divisor);
            legend('clean', 'removed'); legend boxoff
            set(gca,'ygrid','on','xgrid','on');
            set(gca,'yticklabel',[]); ylabel([]);
            xlabel('frequency (relative to line)');
            yl2=get(gca,'ylim');
            hh=get(gca,'children');
            set(hh(1),'color',[1 .5 .5]); set(hh(2), 'color', [ 0 .7 0]);
            set(hh(2),'linewidth', 2);
            yl(1)=min(yl1(1),yl2(1)); yl(2)=max(yl1(2),yl2(2));
            subplot 121; ylim(yl); subplot 122; ylim(yl);
            disp('Finished generating ZapLine figure');
            EEG.automagic.ZapFig = fig1;
        end
    else
        EEG.automagic.filtering.zapline.performed = 'no';
    end
    
    % ZapLine Plus - here no need to transpose the data
    if( ~isempty(zaplineplus))
        
        % ZaplinePlus automatically finds the fline and num comps to
        % remove.
        % We changed the 'clean_data_with_zapline_plus' slitghly by adding
        % a cfg as an output. The cfg contains all variables requiered for
        % plotting (see the next few lines).
        [~, clean, zaplineConfig, analyticsResults, plothandles, cfg] = ... 
                evalc('clean_data_with_zapline_plus(EEG.data, EEG.srate, ''plotResults'', 0)');
            
        % replace data
        EEG.data = clean;
        
        % plot - during only the first call of performFilter
        if ~isfield(zaplineplus,'finalPlot')
            EEG.automagic.filtering.zaplineplus.performed = 'yes';
            EEG.automagic.filtering.zaplineplus.analyticsResults = analyticsResults;
            EEG.automagic.filtering.zaplineplus.zaplineConfig = zaplineConfig;
            disp('Generating ZapLinePlus figure');
            
            fig1 = figure('visible', 'off');
            set(gcf, 'Color', [1,1,1])
            
            ax1 = subplot(1, 2, 1);
            meanhandles = plot(cfg.f,mean(cfg.pxx_raw_log,2),'color','black','linewidth',1.5);
            set(gca,'ygrid','on','xgrid','on');
            set(gca,'yminorgrid','on')
            set(gca,'fontsize',12)
            xlabel('frequency [Hz]');
            ylabel('Power [10*log10 \muV^2/Hz]');
            title({['noise frequency: ' num2str(cfg.noisefreq,'%4.2f') 'Hz'],['raw ratio of noise to surroundings: ' num2str(cfg.ratioNoiseRaw,'%4.2f')]})

                     
            ax2 = subplot(1, 2, 2);
            removedhandle = plot(cfg.f/(cfg.f_noise*cfg.srate),mean(cfg.pxx_removed_log,2),'color','red','linewidth',1.5);
            hold on
            cleanhandle = plot(cfg.f/(cfg.f_noise*cfg.srate),mean(cfg.pxx_clean_log,2),'color','green','linewidth',1.5);
            % adjust plot
            set(gca,'ygrid','on','xgrid','on');
            set(gca,'yminorgrid','on')
            set(gca,'fontsize',12)
            set(gca,'yticklabel',[]); ylabel([]);
            xlabel('frequency relative to noise [Hz]');
            title({['removed power at ' num2str(cfg.noisefreq,'%4.2f') 'Hz: ' num2str(cfg.proportionRemovedNoise*100,'%4.2f') '%']
                ['cleaned ratio of noise to surroundings: ' num2str(cfg.ratioNoiseClean,'%4.2f')]}) 
            xlim([min(cfg.f)-max(cfg.f)*0.0032 max(cfg.f)]);
            xlim([min(cfg.f/(cfg.f_noise*cfg.srate))-max(cfg.f/(cfg.f_noise*cfg.srate))*0.003 max(cfg.f/(cfg.f_noise*cfg.srate))]);
        
            legend(ax1,[meanhandles],{'raw data'},'edgecolor',[0.8 0.8 0.8]);     
            legend(ax2, [cleanhandle,removedhandle],{'clean data','removed data'},'edgecolor',[0.8 0.8 0.8]);      
            fig1.Position = [10 10 640 400];
            
            EEG.automagic.ZapFigPlus = fig1;  
            disp('Finished generating ZapLinePlus figure');
        end

    else
        EEG.automagic.filtering.zaplineplus.performed = 'no';
    end
    
    % 
    if ~isempty(firws) && ~isempty(firws.low)
        EEG.automagic.filtering.firws.low.performed = 'yes';

        [~, EEG, com, ~] = evalc(firws.low.com(7:end));
        args = strsplit(erase(com, ['''', ';', '(', ')']), ',');
        for i = 2:2:(length(args)-1)
            EEG.automagic.filtering.firws.low.(strtrim(erase(args{i}, "'"))) = strtrim(erase(args{i+1}, "'"));
        end
    else
        EEG.automagic.filtering.firws.low.performed = 'no';
    end    
    
    if( ~isempty(low) && (isempty(firws) || isempty(firws.low)))
        [out, EEG, ~ , b] = evalc('pop_eegfiltnew(EEG, 0, low.freq, low.order)');
        splits = strsplit(out, '\n');
        curoff_line = strsplit(splits{4}, ' ');
        cuttoff_freq = curoff_line{end-1};
        
        EEG.automagic.filtering.lowpass.performed = 'yes';
        EEG.automagic.filtering.lowpass.freq = low.freq;
        EEG.automagic.filtering.lowpass.order = length(b)-1;
        EEG.automagic.filtering.lowpass.transitionBandWidth = 3.3 / (length(b)-1) * EEG.srate;
        EEG.automagic.filtering.lowpass.cutoff_freq = str2double(cuttoff_freq);
    else
        EEG.automagic.filtering.lowpass.performed = 'no';
    end
    
end

end