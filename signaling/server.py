from aiohttp import web

routes = web.RouteTableDef()

@routes.get("/")
async def index(request):
    return web.Response(text="Signaling server OK")

@routes.post("/offer")
async def offer(request):
    data = await request.json()
    # Placeholder: qui andrà la gestione dell'SDP
    return web.json_response({"answer": "dummy-answer", "sdp": data.get("sdp", "")})

app = web.Application()
app.add_routes(routes)

if __name__ == "__main__":
    web.run_app(app, port=8081)
