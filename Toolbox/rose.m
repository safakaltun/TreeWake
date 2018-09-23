f = figure;s1 = subplot(1,2,1);s2 = subplot(1,2,2);
[figure_handle1,count1,speeds1,directions1,Table1] = WindRose(m.Data.Wdir_41m.value,m.Data.Wsp_44m_mean.value,'axes',s1);
[figure_handle2,count2,speeds2,directions2,Table2] =  WindRose(m.Data.Wdir_44m.value,m.Data.Wsp_44m_mean.value,'axes',s2);