REMPT="/root/tmp/"
FPFX=$(basename $(readlink -nf $0) | rev | cut -c4- | rev)
SCRNM=$FPFX"-lxc.sh"

for srv in master w01 w02
do
	echo "lxc exec $srv -- bash -c 'mkdir -p $REMPT'"
	echo "lxc file push ./$SCRNM $srv$REMPT$SCRNM"
	echo "lxc exec $srv -- bash -c '$REMPT$SCRNM'"
done
