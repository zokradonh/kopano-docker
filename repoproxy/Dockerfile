FROM nginx:alpine

COPY default.conf start.sh /buildproxy/
RUN chmod a+x /buildproxy/start.sh

CMD ["/buildproxy/start.sh"]