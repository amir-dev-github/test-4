#!/bin/bash

for ii in In ; do
for jj in Se  ; do

mkdir -p $ii$jj

cp $ii.psf $ii$jj/ 2>/dev/null || true
cp $jj.psf $ii$jj/ 2>/dev/null || true
cd $ii$jj

if [ "$ii" = "In" ]
then
an1=49
mass1=114.818
elif [ "$ii" = "Ga" ]
then
an1=31
mass1=69.723
fi

if [ "$jj" = "O" ]
then
an2=8
mass2=15.999
elif [ "$jj" = "S" ]
then
an2=16
mass2=32.066
elif [ "$jj" = "Se" ]
then
an2=34
mass2=78.96
elif [ "$jj" = "Te" ]
then
an2=52
mass2=127.8
fi

cat > mx.fcbuild.fdf << EOF
SystemLabel	mx

NumberOfSpecies	2
NumberOfAtoms		9

%block ChemicalSpeciesLabel
EOF

echo    1    $an1    $ii >> mx.fcbuild.fdf
echo    2    $an2    $jj >> mx.fcbuild.fdf

cat >> mx.fcbuild.fdf << EOF
%endblock ChemicalSpeciesLabel

LatticeConstant 1.00 Ang
%block LatticeVectors
EOF

# خواندن خطوط از فایل mx.out اصلی در پوشه بالاتر (../../mx.out)
LineRelaxed=$(grep -n 'Relaxed atomic coordinates' ../../mx.out | awk -F":" '{print $1}')
Linea1=$(($LineRelaxed+1))
Linea2=$(($LineRelaxed+2))
Linea3=$(($LineRelaxed+3))
Linea4=$(($LineRelaxed+4))
Linea5=$(($LineRelaxed+5))
Linea6=$(($LineRelaxed+6))
Linea7=$(($LineRelaxed+7))
Linea8=$(($LineRelaxed+8))
Linea9=$(($LineRelaxed+9))

Linev1=$(($LineRelaxed+12))
Linev2=$(($LineRelaxed+13))
Linev3=$(($LineRelaxed+14))

awk "NR==$Linev1" ../../mx.out >> mx.fcbuild.fdf
awk "NR==$Linev2" ../../mx.out >> mx.fcbuild.fdf
awk "NR==$Linev3" ../../mx.out >> mx.fcbuild.fdf

cat >> mx.fcbuild.fdf << EOF
%endblock LatticeVectors

AtomicCoordinatesFormat NotScaledCartesianAng
%block AtomicCoordinatesAndAtomicSpecies
EOF

xyzAtom1=$(awk "NR==$Linea1" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )
xyzAtom2=$(awk "NR==$Linea2" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )
xyzAtom3=$(awk "NR==$Linea3" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )
xyzAtom4=$(awk "NR==$Linea4" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )
xyzAtom5=$(awk "NR==$Linea5" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )
xyzAtom6=$(awk "NR==$Linea6" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )
xyzAtom7=$(awk "NR==$Linea7" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )
xyzAtom8=$(awk "NR==$Linea8" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )
xyzAtom9=$(awk "NR==$Linea9" ../../mx.out  | awk  '{print $1,$2,$3,$4}'  )

echo $xyzAtom1  $mass2 >> mx.fcbuild.fdf
echo $xyzAtom2  $mass1 >> mx.fcbuild.fdf
echo $xyzAtom3  $mass2 >> mx.fcbuild.fdf
echo $xyzAtom4  $mass1 >> mx.fcbuild.fdf
echo $xyzAtom5  $mass2 >> mx.fcbuild.fdf
echo $xyzAtom6  $mass2 >> mx.fcbuild.fdf
echo $xyzAtom7  $mass1 >> mx.fcbuild.fdf
echo $xyzAtom8  $mass1 >> mx.fcbuild.fdf
echo $xyzAtom9  $mass2 >> mx.fcbuild.fdf

cat >> mx.fcbuild.fdf << EOF
%endblock AtomicCoordinatesAndAtomicSpecies

SuperCell_1	3
SuperCell_2	3
SuperCell_3	0
EOF

fcbuild < mx.fcbuild.fdf

cat > mx.ifc.fdf << EOF
SystemLabel	mx

NumberOfSpecies	2

%block ChemicalSpeciesLabel
EOF

echo    1    $an1    $ii >> mx.ifc.fdf
echo    2    $an2    $jj >> mx.ifc.fdf

cat >> mx.ifc.fdf << EOF
%endblock ChemicalSpeciesLabel

%block PS.lmax
  In  1
  Se  2
%endblock PS.lmax

PAO.BasisSize          DZP
#PAO.SplitNorm         0.154

PAO.EnergyShift 0.15 eV

#spin spin-orbit
MeshCutoff           200. Ry

DM.MixingWeight       0.1
DM.Tolerance          1.d-4
DM.NumberPulay         4
DM.UseSaveDM		true

ElectronicTemperature   300 K

UseSaveData		true

xc.functional		GGA
xc.authors		PBE

EOF

cat FC.fdf >> mx.ifc.fdf

siesta < mx.ifc.fdf | tee mx.ifc.out

cat >> mx.fcbuild.fdf << EOF
BandLinesScale  ReciprocalLatticeVectors
%block BandLines
1     0.00000  0.000000  0.0   \Gamma
100   0.33333	0.666667 0.0   \K
100   0.50000  0.500000  0.0   \M
100   0.00000  0.000000  0.0   \Gamma 
%endblock BandLines
EOF

vibra < mx.fcbuild.fdf

cp ../$ii.psf . 2>/dev/null || true
cp ../$jj.psf . 2>/dev/null || true

rm -f $ii.psf $jj.psf

cd ..
done
done
