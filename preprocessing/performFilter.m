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
parse(p, varargin{:});
notch = p.Results.notch;
high = p.Results.high;
low = p.Results.low;
firws = p.Results.firws;
zapline = p.Results.zapline;

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
    warning(['Input argument to notch filter is not complete. notch.freq',...
        'must be provided. The default will be used.'])
    zapline = defaults.zapline;
end
%% Perform filtering
EEG.automagic.filtering.performed = 'no';
if( ~isempty(high) || ~isempty(low) || ~isempty(notch) || ~isempty(zapline) || ~isempty(firws))
    EEG.automagic.filtering.performed = 'yes';
    
    if ~isempty(firws)
        EEG.automagic.filtering.firws.performed = 'yes';

        [~, EEG, com, ~] = evalc(firws.com(7:end));
        args = strsplit(erase(com, ["'", ';', '(', ')']), ',');
        for i = 2:2:(length(args)-1)
            EEG.automagic.filtering.firws.(strtrim(args{i})) = strtrim(args{i+1});
        end
    else
        EEG.automagic.filtering.firws.performed = 'no';
    end

    if( ~isempty(high) &&  isempty(firws))
        [~, EEG, ~ , b] = evalc('pop_eegfiltnew(EEG, high.freq, 0, high.order)');
        EEG.automagic.filtering.highpass.performed = 'yes';
        EEG.automagic.filtering.highpass.freq = high.freq;
        EEG.automagic.filtering.highpass.order = length(b)-1;
        EEG.automagic.filtering.highpass.transitionBandWidth = 3.3 / (length(b)-1) * EEG.srate;
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
            % disp('proportion of non-DC power removed:');
            % disp(nt_wpwr(x-y)/nt_wpwr(nt_demean(x)));
            fig2 = 101;
            nfft = 1024;
            %         figure(fig2); clf;
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
    
    if( ~isempty(low) &&  isempty(firws))
        [~, EEG, ~ , b] = evalc('pop_eegfiltnew(EEG, 0, low.freq, low.order)');
        EEG.automagic.filtering.lowpass.performed = 'yes';
        EEG.automagic.filtering.lowpass.freq = low.freq;
        EEG.automagic.filtering.lowpass.order = length(b)-1;
        EEG.automagic.filtering.lowpass.transitionBandWidth = 3.3 / (length(b)-1) * EEG.srate;
    else
        EEG.automagic.filtering.lowpass.performed = 'no';
    end
    
end

end