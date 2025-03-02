FROM nginx:1.15.8

ADD static/fruit.json /usr/share/nginx/html/.
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]