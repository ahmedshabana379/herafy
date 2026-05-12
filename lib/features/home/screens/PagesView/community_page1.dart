import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_cubit.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_state.dart';
import 'package:herafy/features/screens/widgets/post_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key, this.scrollController});
  final ScrollController? scrollController;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    context.read<SocialCubit>().getPosts();
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController!.position.pixels >= widget.scrollController!.position.maxScrollExtent - 200) {
      context.read<SocialCubit>().loadMorePosts();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        final cubit = context.read<SocialCubit>();
        if (state is GetPostsLoading && cubit.posts.isEmpty) return const Center(child: CircularProgressIndicator());
        return RefreshIndicator(
          onRefresh: () async => await cubit.getPosts(isRefresh: true),
          child: ListView.builder(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: cubit.posts.length,
            itemBuilder: (context, index) => PostCard(post: cubit.posts[index]),
          ),
        );
      },
    );
  }
}