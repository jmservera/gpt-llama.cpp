FROM gcc:13.1.0 as builder

# Uncomment the following line to use the Intel GPU
# and use it with docker run --privileged --device="/dev/dri" --device=/dev/dxg -v /usr/lib/wsl:/usr/lib/wsl --net=host -e LIBVA_DRIVER_NAME=iHD -e DISPLAY=$DISPLAY -it -v $(pwd)/open_llama_7b/:/llama/models/7B/ llamabuild sh
# RUN apt install intel-opencl-icd clinfo -y
# ENV LLAMA_CLBLAST=1


RUN apt update && apt install python3-pip git-lfs -y

WORKDIR /llama
# RUN git clone https://huggingface.co/openlm-research/open_llama_7b
RUN git clone https://github.com/ggerganov/llama.cpp

RUN apt install libclblast-dev -y
RUN cd llama.cpp && \
    make LLAMA_CLBLAST=${LLAMA_CLBLAST} && \
    python3 -m pip install -r requirements.txt --break-system-packages

# RUN cd llama.cpp && python3 convert.py ../open_llama_7b && mv ggml-model-f16.bin models

FROM alpine:3.18

COPY --from=builder /llama/llama.cpp/main /usr/bin/main

# llama.cpp/main -m models/7B/ggml-model-f16.bin -p "Hello man! How are you doing? Please, tell me a story about a pink dove."
# llama.cpp/main -m models/7B/ggml-model-f16.bin -n 256 --repeat_penalty 1.0 --color -i -r "User:" -p "User: Hello, Bob.\n Bob: Hello. How may I help you today?"


