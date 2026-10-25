FROM oven/bun:1.2.22
WORKDIR /app
COPY r144_s311_eval/ /app/
ENV PORT=3000
EXPOSE 3000
CMD ["bun", "run", "index.ts"]
