function plan = buildfile
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask

% Create a plan from task functions
plan = buildplan(localfunctions);

% Add the "check" task to identify code issues
plan("check") = CodeIssuesTask('tbx', InfoThreshold = 0, WarningThreshold=0);

% Add the "test" task to run tests
plan("test") = TestTask(SourceFiles = "tbx/skewdist", ...
    TestResults = "public/results.html", ...
    CodeCoverageResults = ["public/coverage.html", "public/coverage.xml"]);

plan('doc') = DocMakerTask( ...
    fullfile( currentProject().RootFolder, "tbx", "doc", "**", "*.md"), ...
    Interpreter="latex");

% Make the "archive" task the default task in the plan
plan.DefaultTasks = "test";

% Make the "archive" task dependent on the "check" and "test" tasks
plan("archive").Dependencies = ["check" "test" "doc"];
end

function archiveTask(~)
% Create MLTBX file
v = ver('skewdist').Version;
opts = matlab.addons.toolbox.ToolboxOptions('tbx', "5fbc1d56-62b5-41ed-a35f-efe40bd86ffb");
opts.ToolboxName = "Skewed Distributions";
opts.PackageName = "SkewedDistributions";
opts.AuthorCompany = 'MathWorks';
opts.AuthorEmail = 'ebenetce@mathworks.com, kdeeley@mathworks.com, jdoty@mathworks.com';
opts.AuthorName = 'Eduard Benet, Ken Deeley, and Justin Doty';
opts.Description = 'Collection of skewed and two-piece distributions commonly used for tail-risk applications.';
opts.OutputFile = "releases/skewdists.mltbx";
opts.Summary = 'Collection of skewed and two-piece distributions';
opts.ToolboxGettingStartedGuide = fullfile(currentProject().RootFolder,'tbx','doc','mfiles','GettingStarted.m');
opts.ToolboxVersion = v;
matlab.addons.toolbox.packageToolbox(opts)
end
