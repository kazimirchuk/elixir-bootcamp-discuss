import {Socket} from "phoenix"

const socket = new Socket("/socket", {
  params: {
    token: window.userToken
  }
});

socket.connect()

const createSocket = (topicId) => {
  if (!topicId) {
    console.log('Could not create socket. Topic ID is not defined.')

    return;
  }

  const channel = socket.channel(`comments:${topicId}`, {})

  channel.join()
    .receive("ok", ({ comments }) => {
      if (!comments || !comments.length) {
        return;
      }

      renderComments(comments);
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.on(`comments:${topicId}:new`, ({ comment: { content, user } }) => {
    const list = document.querySelector('[data-list="comments"]');

    const newComment = list.lastChild.cloneNode();

    newComment.textContent = `<div class="secondary-content">${user ? user.email : 'Anonymous'}</div><div>${content}</div>`;

    list.appendChild(newComment);
  });

  const button = document.querySelector('[data-button="add-comment"]')

  button.addEventListener('click', () => {
    const commentInput = document.querySelector('[data-input="comment"]');
    const comment = commentInput.value;

    if (!comment) {
      return;
    }

    channel.push('comments:add', { comment });

    commentInput.value = '';
  })
}

function renderComments(comments) {
  const renderedComments = comments.map(({ content, user }) => {
    return `<li class="collection-item"><div class="secondary-content">${user ? user.email : 'Anonymous'}</div><div>${content}</div></li>`
  });

  const list = document.querySelector('[data-list="comments"]');

  list.innerHTML = renderedComments.join('');
}

window.createSocket = createSocket;
