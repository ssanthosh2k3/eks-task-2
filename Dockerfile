FROM --platform=linux/arm64 nginx:alpine
COPY app/index.html /usr/share/nginx/html/index.html
CMD ["nginx", "-g", "daemon off;"]
