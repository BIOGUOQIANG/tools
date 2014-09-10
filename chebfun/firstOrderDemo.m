%% First order demo
% AB, 2014/07/24
%

%% Colour coded variables when plotting expression trees:
u = treeVar([1 0 0]);
v = treeVar([0 1 0]);
w = treeVar([0 0 1]);
f = diff(v) + v - 28*u + u.*w; 
treeVar.plotTree(f.tree)

%% First order initial value problem
dom = [0, 1];
N = chebop(@(u) diff(u) + u, dom);
N.lbc = 1;
u = N\0
plot(u), shg
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of initial condition: %4.2e.\n\n', ...
    norm(feval(N.lbc(u), dom(1))))

%% First order initial value problem, with different coefficient on u'
dom = [0, 1];
N = chebop(@(u) .1*diff(u) + u, dom);
N.lbc = 1;
u = N\0
plot(u), shg
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of initial condition: %4.2e.\n\n', ...
    norm(feval(N.lbc(u), dom(1))))

%% Problem with a variable coefficient
dom = [0, 2];
N = chebop(@(x, u) .1*diff(u) + sin(4*x).*u, dom);
N.lbc = 1;
u = N\0
plot(u), shg
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of initial condition: %4.2e.\n\n', ...
    norm(feval(N.lbc(u), dom(1))))

%% Problem with a variable coefficient and an affine part
dom = [0, 2];
N = chebop(@(x, u) .1*diff(u) + sin(4*x).*u + .05*cos(x), dom);
N.lbc = 1;
u = N\0
plot(u), shg
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of initial condition: %4.2e.\n\n', ...
    norm(feval(N.lbc(u), dom(1))))

%% Final value problem:
dom = [0, 1];
N = chebop(@(u) 0.5*diff(u) + u, dom);
N.rbc = 1;
u = N\0
plot(u), shg
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of final condition: %4.2e.\n\n', ...
    norm(feval(N.rbc(u), dom(end))))

%% Second order initial value problem
dom = [0, 1];
N = chebop(@(x,u) diff(u, 2) + u, dom);
N.lbc = @(u) [u-1; diff(u)];
u = N\0
plot(u), shg
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of initial condition: %4.2e.\n\n', ...
    norm(feval(N.lbc(u), dom(1))))

%% Problem with a variable coefficient
dom = [0, 2];
N = chebop(@(x, u) .1*diff(u, 2) + sin(4*x).*u, dom);
N.lbc = @(u) [u-1; diff(u)];
u = N\0
plot(u), shg
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of initial condition: %4.2e.\n\n', ...
    norm(feval(N.lbc(u), dom(1))))


%% Problem with a variable coefficient and an affine part
dom = [0, 2];
N = chebop(@(x, u) .1*diff(u, 2) + sin(4*x).*u + .05*cos(x), dom);
N.lbc = @(u) [u-1; diff(u)];
u = N\0
plot(u), shg
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of initial condition: %4.2e.\n\n', ...
    norm(feval(N.lbc(u), dom(1))))

%% van der Pol
mu = 10;
dom = [0, 50];
vdpFun = @(y) diff(y, 2) - mu.*(1-y.^2).*diff(y) + y;
N = chebop(vdpFun, dom);
N.lbc = @(u) [u-2; diff(u)];
tic,
y = N\0;
toc
plot(y), shg
% Show where breakpoints got introduced
hold on, plot(y.domain, y(y.domain),'k*')
hold off
%% Second order final value problem
dom = [0, 1];
N = chebop(@(u) 0.5*diff(u, 2) + u, dom);
N.rbc = @(u) [u-2; diff(u)];
u = N\0
plot(u)
fprintf('Norm of residual: %4.2e.\n', norm(N(u)))
fprintf('Residual of final condition: %4.2e.\n\n', ...
    norm(feval(N.rbc(u), dom(end))))

%% Coupled system - Lotka-Volterra
dom = [0, 50];
N = chebop(@(t,u,v) [diff(u) - u + u.*v; ...
    diff(v) + v - u.*v], dom);
N.lbc = @(u,v) [u-1.2; v-1.2];
uv = N\0
plot(uv,'linewidth', 2)
legend('u','v')
title('Lotka-Volterra, solved with chebop IVP \.','fontsize',14)
%% Coupled system -- Lorenz equation
dom = [0, 10];
op = @(t, u, v, w) [diff(u) + 10*u - 10*v; ...
    diff(v) + v - 28*u + u.*w; ...
    diff(w) + (8/3).*w - u.*v];
N = chebop(op, dom);
N.lbc = @(u,v,w) [u+14; v+15; w-20];
tic,
uvw = N\0;
toc
u = uvw{1}; v = uvw{2}; w = uvw{3};
plot3(u, v, w), view(20,20)
axis([-20 20 -40 40 5 45]), grid on
xlabel 'x(t)', ylabel 'y(t)', zlabel 'z(t)'
title('A 3D Trajectory of the Lorenz Attractor - Chebfun solution', ...
    'Fontsize', 14)

% Plot the solution components
figure
plot(uvw)
hold on
ud = u.domain;
plot(ud,u(ud),'k*'), plot(ud,v(ud),'k*'), plot(ud,w(ud),'k*')
legend('u','v','w')
hold off
%% Higher order coupled system -- IVP
dom = [0, 4];
N = chebop(@(t,u,v) [diff(u,2) - u + u.*v; diff(v,2) + v - u.*v], dom);
N.lbc = @(u,v) [u-1.2; diff(u); v-1.5; diff(v)-1];
uv = N\0
plot(uv,'linewidth', 2)
legend('u','v')

%% Higher order coupled system -- FVP
dom = [0, 4];
N = chebop(@(t,u,v) [diff(u,2) - u + u.*v; diff(v,2) + v - u.*v], dom);
N.rbc = @(u,v) [u-1.2; diff(u); v-1.5; diff(v)];
uv = N\0
plot(uv,'linewidth', 2)
legend('u','v','location','nw')