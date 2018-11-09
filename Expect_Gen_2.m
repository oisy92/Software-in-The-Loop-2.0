function [M] = Expect_Gen_2(SIM_Title,SIM_Param_Initial, SIM_Param_Final, SIM_Param_Initial_Value, SIM_Param_Final_Value,SIM_Speed, SIM_Num, Geofence, log_directory)

mkdir('~/ardupilot/ArduCopter/SITL_Scripts');

copyfile FP.waypoints ~/ardupilot/ArduCopter/SITL_Scripts

delete('~/ardupilot/ArduCopter/*.exp');

TimeDay = char(datetime('now','Format','d'));
TimeMonth = char(datetime('now','Format','MM'));
TimeYear = char(datetime('now','Format','y'));
TimeHour = char(datetime('now','Format','HH'));
TimeMin = char(datetime('now','Format','mm'));
str_mkdir = '%s-%s-%s-%s:%s';
Date = sprintf(str_mkdir,TimeDay,TimeMonth,TimeYear,TimeHour,TimeMin);
mkdir(log_directory,Date);


timer = fopen('~/Dropbox/SITL_2.0/Run.sh');
    [~,~] = size(timer);
    tline = 0;
    script_data = {};
    while tline ~=-1
    tline = fgetl(timer);
    if tline ~=-1
        script_data = [script_data;tline];
        M = script_data;
    end
    end
    str5 = 'T=`date +%%T -r %s/%s`';
    string5 = sprintf(str5, char(log_directory), char(Date));
    %M = string5;
    script_data(5,1) = {string5};
    script_data(27,1) = {string5};
    fclose(timer);

for t = 1:length(SIM_Title) %CREATING LOG FOLDERS
    
str_SIM_Title = '/%s/%s';
sent_SIM_Title = sprintf(str_SIM_Title,char(Date),char(SIM_Title(t))); %11-04-2017/RCF01

full_directory = strcat(log_directory,sent_SIM_Title); %~/Ardupilot_Logs/%11-04-2017/RCF01
mkdir(full_directory);
    
end

for i = 1:length(SIM_Title) %%CHANGE

	for j = 1:SIM_Num(i) %%CHANGE
        
            title = '~/ardupilot/ArduCopter/SITL_Scripts/%s_%g.exp';
            str_title = sprintf(title,char(SIM_Title(i)), char(j));
            script = fopen(str_title,'w');
            
           % Enter = '\r';

            string_copy = 'file copy -force ~/ardupilot/ArduCopter/SITL_Scripts/mav.tlog %s/%s/%s\n';
            copy_directory = sprintf(string_copy, char(log_directory), char(Date), char(SIM_Title(i)));
             
            string_rename = 'file rename -force -- %s/%s/%s/mav.tlog %s/%s/%s/%s_%g.tlog\n';
            rename_directory = sprintf(string_rename, char(log_directory), char(Date), char(SIM_Title(i)), char(log_directory), char(Date), char(SIM_Title(i)), char(SIM_Title(i)), char(j));
 
            string_T_rename = 'file rename -force -- %s/%s/%s/mav.tlog %s/%s/%s/T_%s_%g.tlog\n';
            rename_T_directory = sprintf(string_T_rename, char(log_directory), char(Date), char(SIM_Title(i)), char(log_directory), char(Date), char(SIM_Title(i)), char(SIM_Title(i)), char(j));
 
            string_B_rename = 'file rename -force -- %s/%s/%s/mav.tlog %s/%s/%s/B_%s_%g.tlog\n';
            rename_B_directory = sprintf(string_B_rename, char(log_directory), char(Date), char(SIM_Title(i)), char(log_directory), char(Date), char(SIM_Title(i)), char(SIM_Title(i)), char(j));

            %Dynamically Enable/Disable Geofence
            str_GEOFENCE = 'send -- "param set FENCE_ENABLE %g\\\\r"\n';
            sent_GEOFENCE= sprintf(str_GEOFENCE,char(Geofence(i)));

            %Dynamically changing the type and value of initial parameter
            str_SIM_Initial_Param = 'send -- "param set %s %g\\\\r"\n';
            sent_SIM_Initial_Param = sprintf(str_SIM_Initial_Param,SIM_Param_Initial{i}, char(SIM_Param_Initial_Value(i)));

            %Dynamically changing the type and value of final parameter
            str_SIM_Final_Param = 'send -- "param set %s %g\\\\r"\n';
            sent_SIM_Final_Param = sprintf(str_SIM_Final_Param,SIM_Param_Final{i}, char(SIM_Param_Final_Value(i)));

            %Dynamically Changing the simulation speed of tests
            str_SIM_Speed = 'send -- "param set SIM_SPEEDUP %g\\\\r"\n';
            sent_SIM_Speed = sprintf(str_SIM_Speed,char(SIM_Speed(i)));

            %dynamic_title_directory = sprintf(string_title_directory,char(SIM_Title(i)));
            fprintf(script, '#!/usr/bin/expect -f\n');
            fprintf(script, 'package require Expect\n');
            fprintf(script, 'set timeout -1\n');
            fprintf(script, 'spawn bash\n');
            fprintf(script, 'set bash $spawn_id\n');
            fprintf(script, 'spawn sim_vehicle.py\n');
            fprintf(script, 'set sim $spawn_id\n');
            fprintf(script, 'set ::original [clock seconds]\n');
            fprintf(script, 'proc updatethetime {} {\n');
            fprintf(script, 'set now [clock seconds]\n');
            fprintf(script, 'set Timer [expr {$now-$::original}]\n');
            fprintf(script, 'after 500 updatethetime\n');
            fprintf(script, 'if {$Timer > 900} {\n');
            fprintf(script, 'send -- "Timer Finished - Reseting\r"\n');
            fprintf(script, '}\n');
            fprintf(script, '}\n');
            fprintf(script, 'updatethetime\n');
            fprintf(script, 'proc batterydetect {} {\n');
            fprintf(script, 'send -- "bat\\r"\n');
            fprintf(script, 'after 500 batterydetect\n');
            fprintf(script, '}\n');
            fprintf(script, 'batterydetect\n');
            fprintf(script, 'expect {\n');
            fprintf(script, '"DISARMED" {\n');
            fprintf(script, 'sleep 5\n');
            fprintf(script, 'send -- "param set SYSID_SW_MREV 0\\r"\n');
            fprintf(script, sent_SIM_Speed); %%CHANGE
            fprintf(script, 'sleep 5\n');
            fprintf(script, copy_directory);
            fprintf(script, 'sleep 1\n');
            fprintf(script, rename_directory);
            fprintf(script, 'exp_close\n');
            fprintf(script, 'spawn ~/ardupilot/ArduCopter/KillXterm.sh\n');
            fprintf(script, 'close $sim\n');
            fprintf(script, 'close $bash\n');
            fprintf(script, 'wait\n');
            fprintf(script, '}\n');
            fprintf(script, '-re "Timer Finished - Reseting" {\n');
            fprintf(script, 'sleep 5\n');
            fprintf(script, 'send -- "param set SYSID_SW_MREV 0\\r"\n');
            fprintf(script, sent_SIM_Speed);%%CHANGE
            fprintf(script, 'sleep 5\n');
            fprintf(script, copy_directory);
            fprintf(script, 'sleep 1\n');
            fprintf(script, rename_T_directory);
            fprintf(script, 'exp_close\n');
            fprintf(script, 'spawn ~/ardupilot/ArduCopter/KillXterm.sh\n');
            fprintf(script, 'close $sim\n');
            fprintf(script, 'close $bash\n');
            fprintf(script, 'wait\n');
            fprintf(script, '}\n');
            fprintf(script, '"Flight battery:   0%%" {\n');
            fprintf(script, 'sleep 5\n');
            fprintf(script, 'send -- "param set SYSID_SW_MREV 0\\r"\n');
            fprintf(script, sent_SIM_Speed); %%CHANGE
            fprintf(script, 'sleep 5\n');
            fprintf(script, copy_directory);
            fprintf(script, 'sleep 1\n');
            fprintf(script, rename_B_directory);
            fprintf(script, 'exp_close\n');
            fprintf(script, 'spawn ~/ardupilot/ArduCopter/KillXterm.sh\n');
            fprintf(script, 'close $sim\n');
            fprintf(script, 'close $bash\n');
            fprintf(script, 'wait\n');
            fprintf(script,	'}\n');
            fprintf(script,	'"APM: EKF2 IMU1 is using GPS" {\n');
            fprintf(script,	'send -- "param set FENCE_RADIUS 500\\r"\n');
            fprintf(script,	'send -- "param set FENCE_ALT_MAX 120\\r"\n');
            fprintf(script,	sent_GEOFENCE);%%CHANGE
            fprintf(script,	'send -- "mode guided\\r"\n');
            fprintf(script,'exp_continue\n');
            fprintf(script,'}\n');
            fprintf(script,'"GUIDED> Mode GUIDED" {\n');
            fprintf(script,sent_SIM_Initial_Param);%%CHANGE
            fprintf(script,'send -- "arm throttle\\r"\n');
            fprintf(script,'exp_continue\n');
            fprintf(script,'}\n');
            fprintf(script,'"ARMED" {\n');
            fprintf(script,'send -- "takeoff 10\\r"\n');
            fprintf(script,'exp_continue\n');
            fprintf(script,'}\n');
            fprintf(script,'"height 10" {\n');
            fprintf(script,'send -- "wp load FP.waypoints\\r"\n');
            fprintf(script,'exp_continue\n');
            fprintf(script,'}\n');
            fprintf(script,'"APM: Reached command #2" {\n');
            fprintf(script,'send -- "mode land\\r"\n');
            fprintf(script,'exp_continue\n');
            fprintf(script,'}\n');
            fprintf(script,'"APM: Flight plan received" {\n');
            fprintf(script,'send -- "mode auto\\r"\n');
            fprintf(script,'exp_continue\n');
            fprintf(script,'}\n');
            fprintf(script,'"waypoint 2" {\n');
            fprintf(script,sent_SIM_Final_Param);%%CHANGE
            fprintf(script,'exp_continue\n');
            fprintf(script,'}\n');
            fprintf(script,'-re "parameters to mav.parm" {\n');
            fprintf(script,'sleep 1\n');
            fprintf(script,'send -- "param set SYSID_SW_MREV 0\\r"\n');
            fprintf(script, sent_SIM_Speed);
            fprintf(script,'sleep 1\n');
            fprintf(script,'exp_continue\n');
            fprintf(script,'}\n');
            fprintf(script,'}\n');
            fprintf(script,'interact\n');
            fclose(script);

        
end
end
delete('~/ardupilot/ArduCopter/tests.sh');
list = fopen('~/ardupilot/ArduCopter/tests.sh', 'w');
fprintf(list, '#!/bin/bash\n');
fprintf(list, 'cd ~/ardupilot/ArduCopter/SITL_Scripts\n');
fprintf(list, 'chmod a+x *.exp\n');
fprintf(list, 'clear\n');
    for k = 1:length(SIM_Title)
        for m = 1:SIM_Num(k)
            
            line1 = 'sek="STATUS: CONDUCTING TEST %s_%g"';
            statement1= sprintf(line1,char(SIM_Title(k)), char(m));
            fprintf(list, statement1);
            fprintf(list, ';height=$(tput lines);width=$(tput cols)');
            fprintf(list, ';line_length=${#sek}');
            fprintf(list, ';tput cup "$((height/2))" "$((($width-$line_length)/2))"');
            fprintf(list, ';tput civis');
            fprintf(list, ';printf "$sek"');
            line2 = ';./%s_%g.exp |wait|\n';
            statement2 = sprintf(line2, char(SIM_Title(k)), char(m));
            fprintf(list, statement2);
            line3 = 'sed -i ''/\\\\<%s_%g\\\\>/d'' ~/ardupilot/ArduCopter/tests.sh\n';
            statement3= sprintf(line3, char(SIM_Title(k)), char(m));
            fprintf(list,statement3);
            M = line3;
        end
    end
    fclose(list);
    
    Run = fopen('~/ardupilot/ArduCopter/Run.exp', 'w');
    fprintf(Run, '#!/usr/bin/expect -f\n');
    fprintf(Run, 'set timeout -1\n');
    fprintf(Run,  'spawn bash\n');
    fprintf(Run,  'set bash $spawn_id\n');
    fprintf(Run,  'set ::original [clock seconds]\n');
    fprintf(Run,  'proc updatethetime {} {\n');
    fprintf(Run,  'set now [clock seconds]\n');
    fprintf(Run,  'set Timer [expr {$now-$::original}]\n');
    fprintf(Run,  'after 500 updatethetime\n');
    fprintf(Run,  'if {$Timer > 960} {\n');
    fprintf(Run,  'send -- "TIMEUP"\n');
    fprintf(Run,  'set ::original [clock seconds]\n');
    fprintf(Run,  'set now [clock seconds]\n');
    fprintf(Run,  'set Timer [expr {$now-$::original}]\n');
    fprintf(Run,  '}\n');
    fprintf(Run,  '}\n');
    fprintf(Run,  'updatethetime\n');
    fprintf(Run,  'send -- "~/ardupilot/ArduCopter/tests.sh\\n"\n');
    fprintf(Run,  'expect {\n');
    fprintf(Run,  '"TIMEUP" {\n');
    fprintf(Run,  'after 5\n');
    fprintf(Run,  'for {set i 1} {$i <= 10} {incr i} {\n');
    fprintf(Run,  'send -- "\\x1A"\n');
    fprintf(Run,  'send -- "pkill bash\\n"\n');
    fprintf(Run,  'send -- "pkill xterm\\n"\n');
    fprintf(Run,  'send -- "pkill tests\\n"\n');
    fprintf(Run,  'send -- "disown -a\\n"\n');
    fprintf(Run,  '}\n');
    fprintf(Run,  'set Timer 0\n');
    fprintf(Run,  'after 5\n');
    fprintf(Run,  'send -- "~/ardupilot/ArduCopter/tests.sh\\n"\n');
    fprintf(Run,  'exp_continue\n');
    fprintf(Run,  '}\n');
    for b = 1:length(SIM_Title)
        for s = 1:SIM_Num(k)
    strring = '"%s_%g" {\n';
    statementt= sprintf(strring,char(SIM_Title(b)), char(s));
    fprintf(Run, statementt);
    fprintf(Run,  'set Timer 0\n');
    fprintf(Run,  ' exp_continue\n');
    fprintf(Run,  '}\n');
        end
    end
    fprintf(Run,  '}\n');
    fprintf(Run,  'interact\n');
    fclose(Run);
    
    end

