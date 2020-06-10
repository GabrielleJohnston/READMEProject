function ClearSignal=PeakRemover(z,zfs,n)
    ThreeP = AutoPeak(z,zfs);
    m=MidFinder(ThreeP,n);

    m2=round(m(2)*zfs);
    mend=round(m(end)*zfs);

    ClearSignal=[z(1:mend); zeros((m2-mend),1); z(m2:end-1)];
end