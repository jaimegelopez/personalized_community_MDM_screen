%This script processes the data from the in-vivo capecitabine experiments
%where mice were colonized with HD1

%% Import data and perform stats

clear;clc

time = [0, 20, 40, 60, 120, 240]; 
mass_feces = xlsread('MDM_in_feces_blood.xlsx','mass_feces');
IS_feces = xlsread('MDM_in_feces_blood.xlsx','IS_feces');
met_360_feces = xlsread('MDM_in_feces_blood.xlsx','metabolite_360_feces');
met_244_feces = xlsread('MDM_in_feces_blood.xlsx','metabolite_244_feces');

met_360_blood = xlsread('MDM_in_feces_blood.xlsx','metabolite_360_blood');
IS_blood = xlsread('MDM_in_feces_blood.xlsx','IS_blood');
met_246_blood = xlsread('MDM_in_feces_blood.xlsx','metabolite_246_blood');

norm_360_feces = met_360_feces./(IS_feces.*mass_feces);%Met/IS per g
norm_244_feces = met_244_feces./(IS_feces.*mass_feces); %Met/IS per g
norm_360_blood = met_360_blood./(IS_blood.*0.03); %Met/IS per mL
norm_246_blood = met_246_blood./(IS_blood.*0.03);
label_y1 = ' (normalized AUC/g)';
label_y2 = ' (normalized AUC/mL)';

feces_360 = compute_MDM_stats(norm_360_feces);
feces_244 = compute_MDM_stats(norm_244_feces);
blood_360 = compute_MDM_stats(norm_360_blood);
blood_246 = compute_MDM_stats(norm_246_blood);

for i = 1:size(norm_244_feces,2)
    [~,p_244_feces(i)] = ttest2(norm_244_feces(1:6,i),norm_244_feces(7:12,i),'Vartype','unequal','tail','both');
    [~,p_360_feces(i)] = ttest2(norm_360_feces(1:6,i),norm_360_feces(7:12,i),'Vartype','unequal','tail','both');
    [~,p_360_blood(i)] = ttest2(norm_360_blood(1:6,i),norm_360_blood(7:12,i),'Vartype','unequal','tail','both');
    [~,p_246_blood(i)] = ttest2(norm_246_blood(1:6,i),norm_246_blood(7:12,i),'Vartype','unequal','tail','both');
end

%Apply Bonferroni
corrected_p_244_feces = p_244_feces*length(p_244_feces);
corrected_p_244_feces(corrected_p_244_feces > 1) = 1;
corrected_p_360_feces = p_360_feces*length(p_360_feces);
corrected_p_360_feces(corrected_p_360_feces > 1) = 1;
corrected_p_360_blood = p_360_blood*length(p_360_blood);
corrected_p_360_blood(corrected_p_360_blood > 1) = 1;
corrected_p_246_blood = p_246_blood*length(p_246_blood);
corrected_p_246_blood(corrected_p_246_blood > 1) = 1;

%% Plot resulting data

figure
plot(time,feces_244.av2,'r-','LineWidth',2)
hold on
plot(time,feces_244.av1,'k-','LineWidth',2)
errorbar(time,feces_244.av1,feces_244.sem1,'k-','LineWidth',2)
errorbar(time,feces_244.av2,feces_244.sem2,'r-','LineWidth',2)
xlabel('Time after dose (minutes)')
ylabel(strcat('M244',label_y1))
current_ylim = get(gca,'ylim');
ylim([0,current_ylim(2)])
set(gca,'TickDir','out');
box off
legend({'HD-1','Antibiotic'},'FontSize',11)
set(gca,'FontSize',11)
legend('boxoff')
set(gca,'FontName','SansSerif')
print(gcf, '-depsc2', 'feces_244.eps')


figure
plot(time,feces_360.av2,'r-','LineWidth',2)
hold on
plot(time,feces_360.av1,'k-','LineWidth',2)
errorbar(time,feces_360.av1,feces_360.sem1,'k-','LineWidth',2)
errorbar(time,feces_360.av2,feces_360.sem2,'r-','LineWidth',2)
xlabel('Time after dose (minutes)')
ylabel(strcat('M360',label_y1))
set(gca,'TickDir','out');
box off
legend({'HD-1','Antibiotic'},'FontSize',11)
set(gca,'FontSize',11)
legend('boxoff')
set(gca,'FontName','SansSerif')
print(gcf, '-depsc2', 'feces_360.eps')


figure
plot(time,blood_360.av2,'r-','LineWidth',2)
hold on
plot(time,blood_360.av1,'k-','LineWidth',2)
errorbar(time,blood_360.av1,blood_360.sem1,'k-','LineWidth',2)
errorbar(time,blood_360.av2,blood_360.sem2,'r-','LineWidth',2)
xlabel('Time after dose (minutes)')
ylabel(strcat('M360',label_y2))
set(gca,'TickDir','out');
box off
legend({'HD-1','Antibiotic'},'FontSize',11)
set(gca,'FontSize',11)
legend('boxoff')
set(gca,'FontName','SansSerif')
print(gcf, '-depsc2', 'blood_360.eps')


figure
plot(time,blood_246.av2,'r-','LineWidth',2)
hold on
plot(time,blood_246.av1,'k-','LineWidth',2)
errorbar(time,blood_246.av1,blood_246.sem1,'k-','LineWidth',2)
errorbar(time,blood_246.av2,blood_246.sem2,'r-','LineWidth',2)
xlabel('Time after dose (minutes)')
ylabel(strcat('M246',label_y2))
set(gca,'TickDir','out');
box off
legend({'HD-1','Antibiotic'},'FontSize',11)
set(gca,'FontSize',11)
legend('boxoff')
set(gca,'FontName','SansSerif')
print(gcf, '-depsc2', 'blood_246.eps')