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

[fid,errmsg] = fopen(fileout,'wt','n','UTF-8');

if fid == -1
error('figure2latex:FileOperation',...
        errmsg);
end

[~,name,ext] = fileparts(fileout);
filename = sprintf('%s%s',name,ext);

tab = '    ';


fprintf(fid,'%% This file was created using FIGURE2LATEX for MATLAB\n%% %s %s\n\n',datestr(now,'yyyy/mm/dd HH:MM:SS'),filename);
fprintf(fid,'\\documentclass{minimal}\n\n');
    
children = findobj(h,'type','axes');

n = length(children);
paperwidth = 345;

switch n
    case 1
        ratio = inv((sqrt(5)+1)/2);
    case 2
        ratio = 2*sqrt(3);
    otherwise
        ratio = sqrt(2);
end

paperheight = round(paperwidth*ratio);

fprintf(fid,'\\usepackage[papersize={%dpt,%dpt},body={%dpt,%dpt}]{geometry}\n',...
    paperwidth,paperheight,paperwidth,paperheight);
fprintf(fid,'\\usepackage{tikz}\n\n');
fprintf(fid,'\\usetikzlibrary{datavisualization}\n');
fprintf(fid,'\\setlength\\parindent{0pt}\n\n');

fprintf(fid,'\\begin{document}\n%s\n\\end{document}','Hola');

if fclose(fid) == -1
    error('figure2latex:FileOperation',...
        ferror(fid));
end
