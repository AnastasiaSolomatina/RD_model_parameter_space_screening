clear all 
close all
tic

global koffA koffP konA konP RhoA RhoP Phi

%Parameters:
koffA = 0.3;
koffP = 0.3;
konA = 1.0;
konP = 1.0;
RhoA = 1.0;
RhoP = 1.0;
Phi = 0.3;

x = [   1.4805382e+00   1.3591668e+00;
    2.7124764e+00   2.0786497e+00;
    2.3974448e+00   2.1319153e+00;
    2.9018681e+00   2.5047220e+00;
    2.1902536e+00   2.4261811e+00 ];

for it_x = 1:size(x,1)
    clear out xstart

    oracle='oracle_bistab_PAR';
    xstart = x(it_x,:)';

    % dimension of the problem
    dim = length(xstart);
    %set up designCentering options
    inopts.pn = 2; %change p-norm
    inopts.MaxEval= 1500;%3000;
    inopts.SavingModulo = 10;
    inopts.VerboseModulo= 10;

    inopts.Plotting = 'on';

    out = LpAdaptation(oracle,xstart,inopts);

    %plot change of volume per evaluation
    idx_all(:,it_x) = out.cntVec;
    v_all(:,it_x) = out.volVec;
    pw_all(:,it_x) = out.P_empVecWindow;
end

%% visualize

f2=figure(2);

iterSave = length(out.rVec);
set(gcf,'Position',[43,1,513,470]);
%set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
xlim([0.0 3.2]);
ylim([0.0 3.2]);
set(gca,'FontSize',18);
xlabel('k_{PA}, \mum^4 s^{-1}')
ylabel('k_{AP}, \mum^4 s^{-1}')
hold on;
pn = out.opts.pn;
plot(out.xAcc(1,1),out.xAcc(1,2),'b.','MarkerSize',15);
cnt_old = 1;
%t2 = text(8,14,['evaluations 1'],'HorizontalAlignment','left','VerticalAlignment','top','fontsize',18);

for iter=1:1:iterSave
    idx = out.cntVec(iter);
    cnt = find(out.cntAcc <= idx,1,'last');
    plot(out.xAcc(cnt_old+1:cnt,1),out.xAcc(cnt_old+1:cnt,2),'b.','MarkerSize',15);
    cnt_old = cnt; 
    mu = out.muVec(iter,:);
    
    m = plot(mu(1),mu(2),'r.','MarkerSize',15');
    
    pause(0.03)

    if iter<iterSave
        delete(m);
    end

end

%%
save('idx_all.mat', 'idx_all');
save('pw_all.mat', 'pw_all');
save('v_all.mat', 'v_all');

%idx = mean(idx_all,2);
%pw = mean(pw_all,2);
%v = mean(v_all,2);

%mean_est_vol = mean(v_all.*pw_all,2);
est_vol = v_all.*pw_all;
%errhigh = std(v_all.*pw_all,0,2);

% ground truth volume
GT = 1.69;
%plot volume estimation
%figure
%shadedErrorBar(idx(:,1),mean_est_vol, errhigh,'lineprops','-k');
%hold on
%plot([0 max(idx(:,1))],[GT GT])
%set(gca,'FontSize',14);
%xlabel('Evaluations')
%ylabel('Volume Estimation')

figure
for it = 1:size(x,1)
    plot(idx_all(:,it),est_vol(:,it))
    hold on
end
plot([0 max(idx(:,1))],[GT GT])
set(gca,'FontSize',14);
xlabel('Evaluations')
ylabel('Volume Estimation')

MW_vol = movmean(est_vol,5);
MWmean_vol = mean(MW_vol,2);
MWstd_vol = std(MW_vol,0,2);

%plot probability evolution
figure
shadedErrorBar(idx(:,1),MWmean_vol/GT,MWstd_vol/GT,'lineprops','-r');
set(gca,'FontSize',14);
xlabel('Evaluations');
ylabel('Mean Volume');
hold on
plot(idx,ones(size(idx)),'k-');

n_start = 15;

disp(['Volume estimation is ',num2str(mean(MWmean_vol(n_start:end)))]);

toc







    
