FROM rust:latest

RUN apt-get update
RUN apt-get install texlive-xetex -y
RUN cargo install mdbook crowbook
RUN git clone https://github.com/rust-lang/book.git

ADD rustbook /book/2018-edition

WORKDIR /book/2018-edition
RUN cargo run --bin concat_chapters src chapters
RUN cp -r src/img chapters

ADD rustbook chapters
WORKDIR chapters

RUN crowbook rustbook

ARG DROPBOX_API_KEY
RUN curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $DROPBOX_API_KEY" \
    --header "Dropbox-API-Arg: {\"path\": \"/rustbook.pdf\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @rustbook.pdf

RUN curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $DROPBOX_API_KEY" \
    --header "Dropbox-API-Arg: {\"path\": \"/rustbook.epub\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @rustbook.epub