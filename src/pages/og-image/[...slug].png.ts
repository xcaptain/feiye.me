import { Renderer } from "@takumi-rs/core";
import type { APIContext, InferGetStaticPropsType } from "astro";
import { readFile } from "node:fs/promises";
import { getAllPosts } from "@/data/post";
import { getFormattedDate } from "@/utils/date";
import { ogMarkup } from "./_ogMarkup";

const ogWidth = 1200;
const ogHeight = 630;

const renderer = new Renderer({
	loadDefaultFonts: false,
});

const notoSCBuffer = await readFile(
	new URL("../../../public/NotoSansSC-VariableFont_wght.ttf", import.meta.url),
);

const rendererReady = renderer.loadFonts([
	{
		data: notoSCBuffer,
		name: "Noto Sans SC",
		style: "normal",
		weight: 400,
	},
	{
		data: notoSCBuffer,
		name: "Noto Sans SC",
		style: "normal",
		weight: 700,
	},
]);

type Props = InferGetStaticPropsType<typeof getStaticPaths>;

export async function GET(context: APIContext) {
	const { pubDate, title } = context.props as Props;

	const postDate = getFormattedDate(pubDate, {
		month: "long",
		weekday: "long",
	});

	await rendererReady;
	const pngBuffer = await renderer.render(ogMarkup(title, postDate), {
		format: "png",
		height: ogHeight,
		width: ogWidth,
	});
	const png = new Uint8Array(pngBuffer);

	return new Response(png, {
		headers: {
			"Cache-Control": "public, max-age=31536000, immutable",
			"Content-Type": "image/png",
		},
	});
}

export async function getStaticPaths() {
	const posts = await getAllPosts();
	return posts
		.values()
		.filter(({ data }) => !data.ogImage)
		.map((post) => ({
			params: { slug: post.id },
			props: {
				pubDate: post.data.updatedDate ?? post.data.publishDate,
				title: post.data.title,
			},
		}))
		.toArray();
}
