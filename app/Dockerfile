FROM public.ecr.aws/docker/library/nginx:alpine
COPY src/ /usr/share/nginx/html/
EXPOSE 8080
CMD ["nginx","-g","daemon off;"]