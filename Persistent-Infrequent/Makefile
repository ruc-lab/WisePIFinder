CPPFLAGS = -Wall -O3 -std=c++14 -lm -w -mcmodel=medium -g
PROGRAMS = main 

all: $(PROGRAMS)

main:main.cpp \
	BOBHASH32.h BOBHASH64.h params.h ssummary.h WisePIFinder.h LossyStrategy.h
	g++ -o WisePIFinder main.cpp $(CPPFLAGS)

clean:
	rm -f *.o $(PROGRAMS)
