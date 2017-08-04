function varargout = roi_testfig(varargin)
%Purpose: Region of Interest user interface for selecting ROI of an image.
%Date:    04-24-2015
%Version: 6.0
% ROI_TESTFIG MATLAB code for roi_testfig.fig
%      ROI_TESTFIG, by itself, creates a new ROI_TESTFIG or raises the existing
%      singleton*.
%
%      H = ROI_TESTFIG returns the handle to a new ROI_TESTFIG or the handle to
%      the existing singleton*.
%
%      ROI_TESTFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_TESTFIG.M with the given input arguments.
%
%      ROI_TESTFIG('Property','Value',...) creates a new ROI_TESTFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roi_testfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roi_testfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roi_testfig

% Last Modified by GUIDE v2.5 11-Mar-2015 14:10:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roi_testfig_OpeningFcn, ...
                   'gui_OutputFcn',  @roi_testfig_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});    
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before roi_testfig is made visible.
function roi_testfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roi_testfig (see VARARGIN)

global pathnames_cell;
global filenames_cell;
global hROI;
global x_min;
global x_max;
global y_min;
global y_max;

pathnames_cell = [];
filenames_cell = [];
hROI           = [];
x_min          = [];
x_max          = [];
y_min          = [];
y_max          = [];

% global h;
% Choose default command line output for roi_testfig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

clc;

% UIWAIT makes roi_testfig wait for user response (see UIRESUME)
uiwait(handles.figure1);
%h = figure;
%imshow('cameraman.tif');


% --- Outputs from this function are returned to the command line.
function varargout = roi_testfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;

global x_min;
global x_max;
global y_min;
global y_max;
varargout{1} = [x_min x_max y_min y_max];

% --- Executes on button press in pushbutton1.
%ENABLE
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hROI;
global h;

global pathnames_cell;
global filenames_cell;

if ~isempty(pathnames_cell) && ~isempty(filenames_cell)
    h = figure;
    warning('off','images:initSize:adjustingMag');        
    
    [file_path,file_name,file_ext] = fileparts(fullfile(pathnames_cell{1},filenames_cell{1}));
    if (strcmp(file_ext,'.jpg')==1)
        imageROI = imread([file_path '\' file_name file_ext]); %read in standard image for defining ROI
        imshow(imageROI);
    end
    
    if (strcmp(file_ext,'.dng')==1)
        dng_type = 1;
        imageROI = dng2rgb([file_path '\' file_name file_ext],dng_type);
        r = imageROI(:,:,1);
        g = imageROI(:,:,2);
        b = imageROI(:,:,3);
        rn = (r - min(r(:)))./(max(r(:)) - min(r(:)));
        gn = (g - min(g(:)))./(max(g(:)) - min(g(:)));
        bn = (b - min(b(:)))./(max(b(:)) - min(b(:)));
        rgbn(:,:,1) = rn;
        rgbn(:,:,2) = gn;
        rgbn(:,:,3) = bn;       
        image(rgbn);
        xlabel('Cols');
        ylabel('Rows');
        clear('rn','gn','bn','r','g','b','imageROI');
    end    
    
    warning('on','images:initSize:adjustingMag');        
    hROI = imrect(gca, [10 10 100 100]);
    addNewPositionCallback(hROI,@(p) title(mat2str(p,3)));
    fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
    setPositionConstraintFcn(hROI,fcn);  
end

% --- Executes on button press in pushbutton2.
%OK
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hROI;
global x_min;
global x_max;
global y_min;
global y_max;

if ~isempty(hROI) && isvalid(hROI)
    pos = getPosition(hROI);%pos = [xmin ymin xmax ymax width height]
    fprintf('X min  = %d\n',pos(1));
    fprintf('Y min  = %d\n',pos(2));
    fprintf('X max = %d\n',pos(1)+pos(3));
    fprintf('y max = %d\n',pos(2)+pos(4));
    fprintf('Width  = %d\n',pos(3));
    fprintf('Height = %d\n',pos(4));
    delete(hROI);
    hROI = [];
    
    x_min = pos(1);
    x_max = pos(1)+pos(3);
    y_min = pos(2);
    y_max = pos(2)+pos(4);
    
end


% --- Executes on button press in pushbutton3.
%SELECT BUTTON
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global pathnames_cell;
global filenames_cell;

[filenames,pathnames] = uigetfile({'*.jpg;*.dng', ...
    'Image Files (*.jpg,*.dng)'}, ...
    'Pick a file','MultiSelect','off');

if iscell(filenames)
    filenames_cell = filenames;
    pathnames_cell = pathnames;
else
    if ischar(filenames)
        filenames_cell{1} = filenames;
        pathnames_cell{1} = pathnames;
        set(handles.edit2,'String',filenames_cell);    
    else
        set(handles.edit2,'String','');
        pathnames_cell = [];
        filenames_cell = [];
    end
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
