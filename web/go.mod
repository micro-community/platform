module github.com/micro/muweb/backend

go 1.13

require (
	github.com/dghubble/gologin v2.1.0+incompatible // indirect
	github.com/dghubble/gologin/v2 v2.2.0
	github.com/dghubble/sessions v0.1.0 // indirect
	github.com/google/uuid v1.1.1
	github.com/gorilla/securecookie v1.1.1 // indirect
	github.com/micro/go-micro v1.18.1-0.20200123215758-eeb6944ce5ae
	github.com/micro/micro v1.18.1-0.20200123150258-806d0dbc6970
	github.com/micro/protoc-gen-micro v1.0.0 // indirect
	golang.org/x/oauth2 v0.0.0-20191202225959-858c2ad4c8b6
)

replace github.com/micro/micro => github.com/micro/micro v1.18.1-0.20200123150258-806d0dbc6970
