function figure2latex(varargin)

narginchk(0,3);

switch nargin
    case 0
        h = gcf;
        fileout = sprintf('Figure_%d.tex',get(h,'number'));
        replace = true;
    case 1
        if isgraphics(varargin{1},'figure')
            h = varargin{1};
            fileout = sprintf('Figure_%d.tex',get(h,'number'));
            replace = true;
        else
            h = gcf;
            fileout = varargin{1};
            replace = true;
        end
    case 2
        if isgraphics(varargin{1},'figure')
            h = varargin{1};
            fileout = varargin{2};
            replace = true;
        else
            h = gcf;
            fileout = varargin{1};
            if strcmpi(varargin{2},'noreplace')
                replace = false;
            else
                error('figure2latex:noValidOption',...
                    'Unkown option ''%s''.',varargin{2});
            end
        end
    case 3
        h = varargin{1};
        fileout = varargin{2};
        if strcmpi(varargin{3},'noreplace')
            replace = false;
        else
            error('figure2latex:noValidOption',...
                'Unkown option ''%s''.',varargin{3});
        end
end

h = gcf;
fileout = 'test.tex';
replace = true;

if ~isgraphics(h,'figure')
    error('figure2latex:noValidHandle',...
        'Invalid figure handle.');
end

if ~replace
    if exist(fileout,'file')
        [pathstr,name,ext] = fileparts(fileout);
        lastnumbers = arrayfun(@(x) str2double(name(x:end)),1:length(name),'UniformOutput',true);
        lastnumber = find(~isnan(lastnumbers),1,'first');
        if isempty(lastnumber)
            name = sprintf('%s%s%s',name,'_1',ext);
        else
            name = sprintf('%s%d%s',name(1:lastnumber-1),max(lastnumbers)+1,ext);
        end
        fileout = fullfile(pathstr,name);
    end
end

fontsize = [10 9];

[fid,errmsg] = fopen(fileout,'wt','n','UTF-8');

if fid == -1
    error('figure2latex:FileOperation',...
        errmsg);
end

[~,name,ext] = fileparts(fileout);
filename = sprintf('%s%s',name,ext);

tab = '    ';


fprintf(fid,'%% This file was created using FIGURE2LATEX for MATLAB\n%% %s %s\n\n',datestr(now,'yyyy/mm/dd HH:MM:SS'),filename);
fprintf(fid,'\\documentclass[%dpt]{article}\n\n',fontsize(1));
fprintf(fid,'\\usepackage{amsmath,mathptmx}\n\n');

children = findobj(h,'type','axes');
n = length(children);

xlabels = get(children,'Xlabel');
ylabels = get(children,'Ylabel');
xtext = cellfun(@(x)get(x,'String'),xlabels,'uniformoutput',false);
ytext = cellfun(@(x)get(x,'String'),ylabels,'uniformoutput',false);

hf = figure;
ha = axes;

extents = zeros(2*n,4);
textents = zeros(n,2);
xticks = zeros(n,2);

xticks(:,1) = cellfun(@min,get(children,'Xtick'));
xticks(:,2) = cellfun(@max,get(children,'Xtick'));
yticks = cell2mat(get(children,'Ytick'));


for k = 1:n
    ht = text(0,0,xtext{k},'FontName','Times','FontSize',fontsize(1),'Units','Points','Parent',ha);
    extents(k,:) = get(ht,'Extent');
    ht = text(0,0,ytext{k},'FontName','Times','FontSize',fontsize(1),'Units','Points','Parent',ha);
    extents(k+n,:) = get(ht,'Extent');
    ht = text(0,0,strrep(num2str(xticks(n,:)),' ',''),'FontName','Times','FontSize',fontsize(2),'Units','Points','Parent',ha);
    extent = get(ht,'Extent');
    textents(k,1) = extent(3)/2;
    ht = text(0,0,num2str(yticks(n,:).'),'FontName','Times','FontSize',fontsize(2),'Units','Points','Parent',ha);
    extent = get(ht,'Extent');
    textents(k,2) = extent(3);
end

close(hf);

[~,mxlabeli] = max(extents(1:n,4));
maxxlabel = xtext{mxlabeli};
[~,mylabeli] = max(extents(n+1:end,4));
maxylabel = ytext{mylabeli};

exlabel = cellfun(@isempty,xtext);
eylabel = cellfun(@isempty,ytext);

textent = round(max(textents,[],1));
lextent = round([max(extents(1:n,4)) max(extents(n+1:end,4))]);

for k = 1:n
    if ~all(exlabel) && exlabel(k)
        xtext{k} = '\vphantom{X}';
    end
    if ~all(eylabel) && eylabel(k)
        ytext{k} = sprintf('\\vphantom{%s}',maxylabel);
    end
end

switch n
    case 1
        ratio = inv((sqrt(5)+1)/2);
    case 2
        ratio = 2*sqrt(3);
    otherwise
        ratio = sqrt(2);
end

paperwidth = 345;
paperheight = round(paperwidth*ratio);
axesheight = round(paperheight/n-lextent(1)-fontsize(2)*2);
axeswidth = round(paperwidth-sum(textent)-lextent(2));
% paperheight = axesheight*n;

fprintf(fid,'\\usepackage[papersize={%dpt,%dpt},body={%dpt,%dpt}]{geometry}\n',...
    paperwidth,paperheight,paperwidth,paperheight);
fprintf(fid,'\\usepackage{tikz}\n\n');
fprintf(fid,'\\usetikzlibrary{datavisualization}\n');
fprintf(fid,'\\setlength\\parindent{0pt}\n\\pagestyle{empty}\n\n');

fprintf(fid,'\\begin{document}\n');

style = 2;
switch style
    case 1
        stylestr = 'strong colors';
    case 2
        stylestr = 'vary dashing';
    case 3
        stylestr = 'cross marks';
    case 4
        stylestr = 'vary thickness and dashing';
end

for k = n:-1:1
    lh = findobj(children(k),'type','line');
    mm = length(lh);
    fprintf(fid,'\\begin{tikzpicture}\n\\datavisualization [\n');
    fprintf(fid,'scientific axes={width=%dpt,height=%dpt,inner ticks},\n',axeswidth,axesheight);
    fprintf(fid,'all axes={ticks={style={/pgf/number format/precision=2,/pgf/number format/fixed relative}}},\n');
    fprintf(fid,'x axis={label={%s}},\n',latexfy(xtext{k}));
    fprintf(fid,'y axis={label={%s}},\n',latexfy(ytext{k}));
    datastr = sprintf('data%d,',1:mm);
    datastr = datastr(1:end-1);
    fprintf(fid,'visualize as smooth line/.list={%s},\nstyle sheet=%s]\n',datastr,stylestr);
    for m = 1:mm
        fprintf(fid,'data [set=data%d] {\nx, y\n',m);
        xdata = get(lh(m),'XData');
        ydata = get(lh(m),'YData');
        fprintf(fid,'%f,%f\n',[xdata;ydata]);
        if m == mm
            fprintf(fid,'};\n');
        else
            fprintf(fid,'}\n');
        end
    end
    if k > 1
        newline = '\\';
    else
        newline = '';
    end
    fprintf(fid,'\\end{tikzpicture}%s\n',newline);
end

fprintf(fid,'\n\\end{document}');

if fclose(fid) == -1
    error('figure2latex:FileOperation',...
        ferror(fid));
end

function s = latexfy(s)

if regexpi(s,'[_^]')
    s = sprintf('$%s$',s);
end

