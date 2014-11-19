function [out] = GTHTMLtable(NAME, MAT, FORMAT, COLS, COLFORMAT, ROWS, ROWFORMAT, bgcolors, cell_align, fontcolors)
% GTHTMLtable - Generate an HTML page with a table of a matrix.
%                  
% function FName = <a href="matlab: doc GTHTMLtable">GTHTMLtable</a>({NAME},MAT,{FORMAT},{COLS,{COLFORMAT}},{ROWS,{ROWFORMAT}},{flag,{...}},'colormap',map);
%
% This is intended to be a simple way to display 2D or 3D table data
% with support for row and column labels. Most arguments are optional, 
% except for the data to be tabulated. Format specifiers are strings
% using the standard <a href="matlab: help sprintf">printf</a> format style. Data must be a 2D table or 
% cell array. Cell arrays can mix strings and numbers.
%
% NAME   : Title for table, must be a string {OPTIONAL}
% MAT    : matrix to be displayed. Can be a list.
% FORMAT : sprintf style format for MAT elements {OPTIONAL}
% COLS      : Column names for table {OPTIONAL}. List of strings or 
%             vector of numbers. Not both.
% COLFORMAT : sprintf style format for column elements {OPTIONAL}
% ROWS      : Row names for table {OPTIONAL}. List of strings or 
%             vector of numbers. Not both.
% ROWFORMAT : sprintf style format for row elements {OPTIONAL}
% 'show'    : Show output {OPTIONAL} will prevent saving of file 
%             unless 'save' is specified.
% 'save'    : Save output to HTML file {OPTIONAL} if show is not 
%             specified the save is default.
% 'new'     : Open a new window {DEFAULT}
% 'old'     : Do not open a new window {OPTIONAL}
% 'colormap': define colormap to color contents, must be followed 
%             by a colormap such as generated by  <a href="matlab: help hsv">hsv(10)</a>
%
% Note: Labels can be either strings or numbers, not both, mixing 
%       will cause strange behavior.
%       Specifying more row labels than rows will cause the row 
%       labels to be truncated.
%       Specifying more column labels than columns will result in 
%       empty columns.                                            
%       Imaginary numbers are not supported.
%       The colormap option is only supported for numeric arrays.
%
% Example:
% % The simplest form
% <a href="matlab: GTHTMLtable(rand([3 5 2]),'show');">[try]</a> GTHTMLtable(rand([3 5 2]),'show');
% % Using a color map to color contents
% <a href="matlab: GTHTMLtable(rand([3 5 2]),'colormap',hsv(10)/2+0.5,'show');">[try]</a> GTHTMLtable(rand([3 5 2]),'colormap',hsv(10)/2+0.5,'show');
% % with column labels
% <a href="matlab: GTHTMLtable('Table name',[1:4; 10:10:40],{'one' 'two' 'three' 'four'},'show');">[try]</a> GTHTMLtable('Table name',[1:4; 10:10:40],{'one' 'two' 'three' 'four'},'show');
% % with row labels and format specifiers
% <a href="matlab: GTHTMLtable('Table name',[1:4; 10:10:40],'%5.3f',[1:4],'%2.2i',{'one' 'two'},'ROW %s','show','old');">[try]</a> GTHTMLtable('Table name',[1:4; 10:10:40],'%5.3f',[1:4],'%2.2i',{'one' 'two'},'ROW %s','show','old');
% % The output argument is the html code, if the save option is not specified.
% <a href="matlab: html = GTHTMLtable([1:4; 10:10:40],{'first' 'second' 'third' 'fourth'},[1 2],'show')">[try]</a> html = GTHTMLtable([1:4; 10:10:40],{'first' 'second' 'third' 'fourth'},[1 2],'show')
% % The output argument is the html filename, if the save option is specified.
% % Nested tables are supported inside cell arrays.
% <a href="matlab: fname = GTHTMLtable('x',{1 [2:3]' 'three' 'four'; 10 20 30 40; 'a' 'e' 'r' 'o'},{'first' 'second' 'third' 'fourth'},{'1' '2' 'three'},'show','save')">[try]</a> fname = GTHTMLtable('x',{1 [2:3]' 'three' 'four'; 10 20 30 40; 'a' 'e' 'r' 'o'},{'first' 'second' 'third' 'fourth'},{'1' '2' 'three'},'show','save')
%

HTML = '';

%varargin = {[] [] [] [] [] [] [] []};
%for ii = 1:nargin,
%  varargin{ii} = varargin{ii};
%end;

% data store

count = 0; % argument counter
SHOW = 0;  % Show in web browser
NEW = 1;   % open new browser
COLOR = []; % colormap to use
SAVEHTML = 0;   % save html to a file
MATFOUND = 0;   % flag to indicate if data was found
COLSFOUND = 0;  % flag to indicate if column labels were found
ROWSFOUND = 0;  % flag to indicate if row labels were found
% Search through arguments
% while (count<nargin),
%   count = count+1;
%   
%   if (ischar(varargin{count}) && strcmpi(varargin{count},'show') && count>1),
%     % show table in browser
%     SHOW = 1;
%   elseif (ischar(varargin{count}) && strcmpi(varargin{count},'save') && count>1),
%     % save html to a file
%     SAVEHTML = 1;
%   elseif (ischar(varargin{count}) && strcmpi(varargin{count},'new') && count>1),
%     % open new browser window
%     NEW = 1;
%   elseif (ischar(varargin{count}) && strcmpi(varargin{count},'old') && count>1),
%     % use existing browser window
%     NEW = 0;
%   elseif (ischar(varargin{count}) && strcmpi(varargin{count},'colormap') && count>1 && count<nargin),
%     % color cells with colormap specified
%     COLOR = varargin{count+1};
%     count = count + 1;
%   elseif (ischar([varargin{count}]) && count>=3 && count<=7 && ROWSFOUND),
%     % format specifier for row labels
%     ROWFORMAT = varargin{count};
%   elseif (~ischar([varargin{count}]) && count>=2 && count<=6 && COLSFOUND && ~ROWSFOUND),
%     % labels for rows
%     ROWS = varargin{count};
%     ROWSFOUND = 1;
%   elseif (ischar([varargin{count}]) && count>=3 && count<=5 && COLSFOUND),
%     % format specifier for column labels
%     COLFORMAT = varargin{count};
%   elseif (~ischar([varargin{count}]) && count>=2 && count<=4 && MATFOUND && ~COLSFOUND),
%     % labels for columns
%     COLS = varargin{count};
%     COLSFOUND = 1;
%   elseif (ischar([varargin{count}]) && count>=2 && count<=3 && MATFOUND),
%     % format specifier for data 
%     FORMAT = varargin{count};
%   elseif (~ischar([varargin{count}]) && count>=1 && count<=2 && ~MATFOUND),
%     % data
%     MAT = varargin{count};
%     MATname = inputname(count);
%     if isnumeric(MAT),
%       MATmax = max(MAT(:));
%       MATmin = min(MAT(:));
%       MATrange = MATmax - MATmin;
%     end;
%     MATFOUND = 1;
%   elseif (ischar([varargin{count}]) && count ==1),
%     % title of table also filename
%     NAME = varargin{count};
%   end;
% 
% end;

if( nargin < 5 )
    COLFORMAT = '%s';
end

if( nargin < 6 )
    ROWS = [];
end

if( nargin < 7 )
    ROWFORMAT = '%s';
end

% colormap
if ~isempty(COLOR),
  if (~isnumeric(COLOR) || size(COLOR,2)~=3)
    warning('GTHTMLTable:colormap','colormap must be [nx3] array');
    COLOR = [];
  end;
end;

% resize MAT
szmat = size(MAT); 
MAT = reshape(MAT,szmat(1),szmat(2),prod(szmat(3:end)));

% create filename
if (exist('NAME','var')),
  FILENAME = ['TABLE_' NAME '.html'];
else
  FILENAME = 'TABLE.html';
end;
% replace unacceptable characters in filename
I = find(FILENAME=='\' | FILENAME==' ' |  FILENAME=='(' |  FILENAME==')' |  FILENAME=='[' |  FILENAME==']' |  FILENAME=='*');
FILENAME(I) = '_';

% set default row format
if (~exist('ROWFORMAT','var') && ~isempty(ROWS)),
  if (iscell(ROWS(1))),
    if ischar([ROWS{1}]),
      ROWFORMAT = '%s';
    else
      ROWFORMAT = '%g';
    end;
  else
    if length(ROWS(1))>1,
      ROWFORMAT = '%s';
    else
      ROWFORMAT = '%g';
    end;
  end;
end;
% set default column format
if (isempty(COLFORMAT) && ~isempty(COLS)),
  if (iscell(COLS(1))),
    if ischar([COLS{1}]),
      COLFORMAT = '%s';
    else
      COLFORMAT = '%g';
    end;
  else
    if length(COLS(1))>1,
      COLFORMAT = '%s';
    else
      COLFORMAT = '%g';
    end;
  end;
end;
% set default data format
if isempty(FORMAT),
  if ischar(MAT(1)),
    FORMAT = '%s';
  else
    FORMAT = '%g';
  end;
end;


% number of columns to be displayed
if ~isempty(ROWS),
  % add a blank cell if row labels are present
  szcols = size(MAT,2)+1;
else
  szcols = size(MAT,2);
end;

% HTML table
HTML = [HTML sprintf('<TABLE BGCOLOR=gray ALIGN=center>')];
% Table title row
if exist('NAME','var'),
  HTML = [HTML sprintf('<TR><TH COLSPAN=%g ALIGN=CENTER BGCOLOR=WHITE>%s</TH></TR>',szcols,NAME)];
end;

if( nargin < 8 || isempty(bgcolors)  )
    bgcolors = repmat({'white'}, size(MAT));
end
    
if( nargin < 9 || isempty(cell_align)  )
    cell_align = repmat({'center'}, size(MAT));
end
    
if( nargin < 10 || isempty(fontcolors)  )
    fontcolors = repmat({'black'}, size(MAT));
end

% cycle through pages
for ipage = 1:size(MAT,3),
  page = MAT(:,:,ipage);
  if (size(MAT,3) > 1),
    % display page line
    HTML = [HTML sprintf('<TR><TH COLSPAN=%g ALIGN=CENTER BGCOLOR=ivory>%s(:,:,%g)</TH></TR>',szcols,MATname,ipage)];
  end;
  % Column labels
  if ~isempty(COLS),
    HTML = [HTML sprintf('<TR>')];
    if (~isempty(ROWS) && length(COLS)<=size(page,2)),
      HTML = [HTML sprintf('<TD></TD>')];
    end;
    if (iscell(COLS)),
      HTML = [HTML sprintf('<TR>')];
      for ii = 1:size(COLS,1),
            omit_cols = 0;
          for jj = 1:size(COLS,2),
              if( omit_cols > 0 )
                  omit_cols = omit_cols -1;
                continue
              end
              
                if isstruct(COLS{ii,jj})
                    aux_struct = COLS{ii,jj};
                    HTML = [HTML sprintf(['<TH COLSPAN=%g ALIGN=CENTER BGCOLOR=white ALIGN=center>' COLFORMAT '</TH>'], aux_struct.colspan, aux_struct.data )];
                    omit_cols = aux_struct.colspan - 1;
                else
                    HTML = [HTML sprintf(['<TH BGCOLOR=white ALIGN=center>' COLFORMAT '</TH>'],[COLS{ii,jj}])];
                end
          end
          HTML = [HTML sprintf('</TR>\n')];
      end;
    else
      HTML = [HTML sprintf(['<TH BGCOLOR=white ALIGN=center>' COLFORMAT '</TH>'],COLS)];
    end;
    HTML = [HTML sprintf('</TR>\n')];
  end;
  
ignore_row = [];
ignore_col = [];
  
  % format data rows
  for ii = 1:size(page,1),
    HTML = [HTML sprintf('<TR>\n')];  % new row of data

    % add row label to line
    if ~isempty(ROWS),
      if ii<=length(ROWS),
        if (iscell(ROWS)),
          HTML = [HTML sprintf(['<TH BGCOLOR=white ALIGN=center>' ROWFORMAT '</TH>'],[ROWS{ii}])];
        else
          HTML = [HTML sprintf(['<TH BGCOLOR=white ALIGN=center>' ROWFORMAT '</TH>'],ROWS(ii))];
        end;
      else
        HTML = [HTML sprintf('<TH></TH>')];  % empty row 
      end;
    end;

    
    % add data 
    if (iscell(page)), % if data is of type cell array
      for jj = 1:length({page{ii,:}}), % columns of data
        
        if( any( jj == ignore_col & ii == ignore_row) )
            continue
        end
        
          % Extract data if single element cell array
        if iscell(page{ii,jj}) && length(page{ii,jj})==1,
          page{ii,jj} = page{ii,jj}{1};
        end;
        
        str_col_row_span = '';
        if isstruct(page{ii,jj})
            aux_struct = page{ii,jj};
            if( isfield(aux_struct, 'colspan') )
                str_col_row_span = sprintf('COLSPAN="%d" ', aux_struct.colspan );
                page{ii,jj} = aux_struct.data;
                ignore_col = [ignore_col, jj:(jj+aux_struct.colspan)];
                ignore_row = [ignore_row, repmat(ii,1,aux_struct.colspan-1)];
            elseif( isfield(aux_struct, 'rowspan') )
                str_col_row_span = sprintf('ROWSPAN="%d" ', aux_struct.rowspan );
                page{ii,jj} = aux_struct.data;
                ignore_col = [ignore_col, repmat(jj,1,aux_struct.rowspan)];
                ignore_row = [ignore_row, ii:(ii+aux_struct.rowspan-1)];
            end
        end
        
        % process cell based of content type 
        if iscell(page{ii,jj}) && length(page{ii,jj})>1,
          % create a sub table
          tFORMAT = '%s';             % format for sting
          page{ii,jj} = GTHTMLtable(page{ii,jj});
            
        elseif ischar(page{ii,jj}),
          tFORMAT = '%s';             % format for sting
        elseif length(page{ii,jj})>1,
          % create a sub table
          tFORMAT = '%s';             % format for sting
          page{ii,jj} = GTHTMLtable(page{ii,jj});
        else
          if ~exist('FORMAT','var'),
            tFORMAT = '%g';
          else
            tFORMAT = FORMAT;         % use user format
          end;
        end;

        HTML = [HTML sprintf(['<TD %s BGCOLOR=%s ALIGN=%s><font color="%s">' tFORMAT  '</font></TD>'], str_col_row_span, bgcolors{ii,jj}, cell_align{ii,jj}, fontcolors{ii,jj}, page{ii,jj})]; % add data cell
        
      end;
    else  % if data is no a cell array
      if (~isempty(COLOR) && isnumeric(MAT)),
        for icol = 1:size(page,2),
          % color cells according to value
          color = dec2hex( floor(255*interp1((0:1/(size(COLOR,1)-1):1),COLOR,(page(ii,icol)-MATmin)/MATrange)) );
          HTML = [HTML sprintf(['<TD BGCOLOR=#%6s ALIGN=right>' FORMAT  '</TD>'],color',page(ii,icol))]; 
        end;
      else
        HTML = [HTML sprintf(['<TD BGCOLOR=white ALIGN=right>' FORMAT  '</TD>'],page(ii,:))]; 
      end;
    end;
    HTML = [HTML sprintf('\n</TR>')]; % close data row
  end;
end;
HTML = [HTML sprintf('</TABLE>')];  % close table

% Save to html file
if (SAVEHTML),
  FID = fopen(FILENAME,'w');
  fprintf(FID,'%s',HTML);
  fclose(FID);
  disp(sprintf('HTML table saved to file <a href="%s">%s</a>',FILENAME,FILENAME));
  out = FILENAME; % output filename
else
  out = HTML;     % output html code
end;

% display in browser window
if (SHOW),
  if (NEW),
    web(['text://<html>' HTML '</html>'],'-new','-notoolbar');
  else
    web(['text://<html>' HTML '</html>'],'-notoolbar');
  end;
end;


