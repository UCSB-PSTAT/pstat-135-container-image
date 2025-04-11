FROM ucsb/all-spark-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

#RUN R -e "install.packages(c('future'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

RUN conda install -c conda-forge -y\
    r-arrow\
    r-aws.s3\
    r-bench\
    r-bookdown\
    r-ff\
    r-ffbase\
    r-foreach\
    r-future\
    r-keras\
    r-rjdbc\
    r-scattermore\
    r-tensorflow\
    r-tfestimators

#RUN pip install <packages>

USER $NB_USER

