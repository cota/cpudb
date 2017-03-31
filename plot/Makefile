TARGETS := cpudb.svg cpudb.png

all: $(TARGETS)

%.svg: %.plt
	gnuplot -e "set term svg size 580,430 fname 'Arial,10'" $< > $@

%.png: %.plt
	gnuplot -e "set term pngcairo" $< > $@

%.plt: %.dat %-plot.pl %.avg
	./$(basename $@)-plot.pl $< > $@

%.avg: %.dat %-avg.pl
	./$(basename $@)-avg.pl $< > $@

.PRECIOUS: %.avg

%.dat: %.pl
	./$< > $@

clean:
	$(RM) -f $(TARGETS)
	$(RM) -f *.dat *.avg *.plt

.PHONY: all clean
