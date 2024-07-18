function [dx, dy] = subPix(x,y)
    %  subPix: return the vertex of the parabola passing through the
    %  points (x1,y1), (x2,y2)) and (x3,y3))
    %  the outut is the displacement of the vertex wrt the central point
    %  i.e, if (vx,vy) are the coordinates of the vertex, 
    %  vx = x(2) + dx, vy = y(2) + dy
    
    t3 = 1/x(2);
    t4 = x(1) - x(2);
    t5 = 1/t4;
    t6 = x(1)^2;
    t7 = 1/t6;
    t8 = x(2)^2;
    t9 = -t7*t8 + 1;
    t10 = t3*x(1)*t5*t9;
    t11 = 1/x(1);
    t12 = x(3)^2;
    t13 = t11*t12;
    t14 = 1/(t3*t13 - t3*x(3) - t11*x(3) + 1);
    t15 = t14*y(3);
    t16 = t10*t15;
    t17 = t3*t5;
    t18 = -t13 + x(3);
    t19 = y(2)*(x(1)*t17 + t14*t18*t6*t9/(t4^2*t8));
    t20 = x(2)*t5;
    t21 = t11*t20;
    t22 = t14*(-t12*t7 + t18*t21);
    t23 = y(1)*(-t10*t22 - t21);
    t24 = t16/2 - t19/2 - t23/2;
    t25 = -t17*t9 + t7;
    t26 = t3*x(1)*t14*t18*t5;
    t27 = 1/(-t15*t25 + y(1)*(t20*t7 - t22*t25 + t7) + y(2)*(-t17 + t25*t26));
    dx = t24*t27 - x(2);
    dy = (t15 + t22*y(1) + t24^2*t27 - t26*y(2) + dx*(-t16 + t19 + t23)) - y(2);