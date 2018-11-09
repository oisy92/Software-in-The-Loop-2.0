
%Name: Osama Yahya
%Supervisor: Troy Bruggemann
%Status: Completed
%Contact: osamaibrahimsuliman.yahya@connect.qut.edu.au

%Code Description: This code gives the ability to calculate failure
%probability for Software in a Loop ArduPilot. 

%How to use:
%1_Run the code
%2_Choose the directory where the FOLDERS containing tlogs are.
%3_Open probability database in the workspace.

clear all
close all
clc;

%Preparing directory and listing all contents
input = uigetdir();
d = dir (input);
d(~[d.isdir])= []; 
folder = setdiff({d.name},{'.','..'});
f = fullfile(input);
cd (f)

%Comparison strings that we will need later
comp_bat = 'B_log';
comp_time = 'T_log';

%Structuring the probability table
P{1,1} = 'Test Name';
P{1,2} = 'All';
P{1,3} = 'Sucess';
P{1,4} = 'Fail';
P{1,5} = 'Probability';


%MAIN FOLDER LOOP
for folderloop = 1:length(folder)
     ChangeDir = '%s';
     Changedir_str = sprintf(ChangeDir,char(folder(folderloop)));
     cd(Changedir_str)
    files = dir;
    fileslist = struct2cell(files);
    tlogs = length(files(not([files.isdir])));
    testname = '%s';
    testname_Str = sprintf(testname,char(folder(folderloop)));
    
    

  %FILES LOOP
    for filesloop = 1:tlogs
    count_All = 0;
    count_Tim = 0;
    count_Bat = 0;
    com_bat = strncmp(comp_bat,fileslist(1,filesloop),2);
    com_tim = strncmp(comp_time,fileslist(1,filesloop),2);
     if  com_bat == 1 || com_tim == 1
         P_index(folderloop,filesloop) = 0;
     else 
         P_index(folderloop,filesloop) = 1;
     end
   
    C_A = dir();
    C_A = (C_A(not([C_A.isdir])));
    
    C_T = dir('T_*');
    C_T = (C_T(not([C_T.isdir])));
    
    C_B = dir('B_*');
    C_B = (C_B(not([C_B.isdir])));
    
    for file = C_A'
       count_All = count_All+1;
    end

    for tfile = C_T'
        count_Tim = count_Tim +1;
    end

    for bfile = C_B'
        count_Bat = count_Bat +1;
    end
    
    end
    
    %PROBABILITY CALCULATIONS AND PLOTTING
    count_suc = count_All - (count_Tim + count_Bat);
    count_fail = (count_Tim + count_Bat);
    P{folderloop+1,1} = testname_Str;
    P{folderloop+1,2} = count_All;
    P{folderloop+1,3} = count_suc;
    P{folderloop+1,4} = count_fail;
    P{folderloop+1,5} = (count_suc+1)/(count_All+2);
		
	R = count_suc; 
	N = count_All;
	
	c = 1; 	
    for theta = 0:0.01:1
         ptheta_givenD(c) = factorial(N+1)/(factorial(R)*(factorial(N-R)))*theta^R*(1-theta)^(N-R);
         pro{folderloop,c} = ptheta_givenD(c);
         c=c+1;
    end
	ptheta_givenD = ptheta_givenD/sum(ptheta_givenD); %normalize
	
	 P{folderloop+1,6} = ptheta_givenD;  %This is the distribution
     
    
    %Structuring the probability table
    P{1,1} = 'Test Name';
    P{1,2} = 'All';
    P{1,3} = 'Sucess';
    P{1,4} = 'Fail';
    P{1,5} = 'p(H|D)';
    P{1,6} = 'Distribution';

    
    SP = [1:1:count_All-(count_Tim + count_Bat)];
    pnt_s = ones(1,length(SP));    
    FP = [1:1:(count_Tim + count_Bat)];
    pnt_f = zeros(1,length(FP));
    cd(f)
    
    %Calculate probability over all tests. This is the probability of successful mission overall. 
    PUnion = 1-prod(1-P{folderloop+1,5});
  
    
    
end

domain = linspace(0,1,c-1);
figure(1)
for vx = 2:length(folder)+1
    PUnion = 1-prod(1-P{vx,end}(1,:));
    plot(domain,P{vx,6}(1,:), '-o')
    hold on
    
end
grid on
legend (P(2:end,1))
title('Distribution Plot');
xlabel('\theta');
ylabel('p(\theta|D)');
hold off
openvar('P')
