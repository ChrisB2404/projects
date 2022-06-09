%Robot systems toolbox required to run code
%To access toolbox purchase MATLAB suite or get the free trial
clc; clear;
%motor angles
th1 = 0;
th2 = 0;
%heliostat dims (m)
Lab = 0.107188;
Lbc = 0.093175;
Lcd = 0.105475;
%denavit-hartenberg parameters to define robot frames
dhparams = [0 pi/4 Lab th1; 0 pi/4 Lbc th2; 0 0 Lcd 0];
%define rigidBodyTree object
robot = rigidBodyTree;
bodies = cell(3,1);
joints = cell(3,1);
for i = 1:3
    bodies{i} = rigidBody(['body' num2str(i)]);
    if i==1 || i==2 %revolute joints
        joints{i} = rigidBodyJoint(['int' num2str(i)],"revolute");
    else
        joints{i} = rigidBodyJoint(['int' num2str(i)],"fixed");
    end
    setFixedTransform(joints{i},dhparams(i,:),"dh");
    bodies{i}.Joint = joints{i};
    if i == 1 %add first body to base
        addBody(robot,bodies{i},"base")
    else %add current body to previous body by name
        addBody(robot,bodies{i},bodies{i-1}.Name)
    end
end
%laser vector
lvec = [0 0 1];
%wall target
x = input('Target x-coordinate (m):');
y = input('Target y-coordinate (m):');
z = input('Target z-coordinate (m):');
t = [x y z];
min_err = inf; %track lowest error
config = robot.homeConfiguration;
% disp(config(1).JointPosition);
% disp(config(2).JointPosition);
%limits of rotation for motors
m1_lim1 = 0;
m1_lim2 = 2*pi;
m2_lim1 = 115*pi/180;
m2_lim2 = 160*pi/180;
disp('Computing angles...');
for i = m1_lim1:0.01:m1_lim2 %theta1 loop
    config(1).JointPosition = i;
    for j = m2_lim1:0.01:m2_lim2 %theta2 loop
        config(2).JointPosition = j;
        %get transformation from origin to mirror to define normal vector
        tform0 = getTransform(robot, config, 'body2', 'base');
        trvec0 = tform2trvec(tform0);
        tform1 = getTransform(robot, config, 'body3', 'base');
        trvec1 = tform2trvec(tform1);
        %find mirror normal unit vector
        m = trvec1 - trvec0;
        n_u = m/norm(m);
        %find unit vector from mirror to target
        m_t = t - trvec1;
        t_u = m_t/norm(m_t);
        %check for coplanar vectors with scalar triple product
        coplanar = (dot(lvec,cross(n_u,t_u)));
        if abs(coplanar)<=0.005
            %check if mirror normal bisects angle b/w mirror and target
            err = abs(acos(dot(lvec,n_u))-acos(dot(n_u,t_u)));
            if err < min_err
                min_err = err;
                cf1 = 90;
                cf2 = 0;
                th1_0 = i*180/pi;
                th2_0 = j*180/pi; 
                th1 = th1_0 + cf1; %angle 1 with correction factor
                th2 = th2_0 + cf2; %angle 2 with correction factor
            end
        end
    end
end
%display angles and vectors
angles = [th1, th2];
disp(angles);
config(1).JointPosition = th1*pi/180;
config(2).JointPosition = th2*pi/180;
%config = robot.homeConfiguration;
show(robot,config);